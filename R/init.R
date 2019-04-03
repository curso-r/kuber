
#' Create a docker directory with the kuber template for parallelism by expansion
#'
#' @description This function creates a directory with 5 components from the
#' kuber template: a `Dockerfile` (that is designed for expanded parallel taks),
#' an R file `exec.R` (which contains some code that guides how your program
#' should work), a `job-tmpl.yaml` (a template for the yaml files that will lauch
#' the docker jobs), an RDS `list.rds` (which contains `as.list(seq(1, 10))` just
#' so you don't forget to setup the inputs that each job will take) and a `jobs/`
#' folder (where the actual job yaml files will go once you run [kuber_push()]).
#' For more information, please see the sections below.
#'
#' @section Dockerfile:
#' This is a very simple `Dockerfile` based on `rocker/tidyverse` that installs
#' `tidyverse`, `devtools` and `abjutils`, and copies `exec.R` and `list.rds` to
#' the home directory. If you have any extra dependencies or want to use more
#' files for your script, this is where you should add them.
#'
#' @section Exec.R:
#' The `exec.R` file is only a guide for what your script should probably be
#' doing. It gets the number of the current job as its only argument, saves a
#' result file as an RDS and uploads that file to the desired bucket.
#'
#' @section Job-tmpl.yaml:
#' The job template is a very simple file that describes how the job should be
#' run once it is activated by the pod, which is essentially running
#' `Rscript --vanilla exec.R [JOB_NUMBER]`. Since this template uses parallelism
#' via expansion, [kuber_push()] will expand this template into as many job
#' files as you want.
#'
#' @section Jobs/:
#' This is simply a folder that will store the job files once the template is
#' expanded.
#'
#' @section List.rds:
#' This is more of a suggestion than a required file. It contains (by default)
#' a `list()` with each integer from 1 to 10, but actually it could be any list
#' of your choosing. The goal here is to be able to get the arguments for your
#' script just by extracting the element with index equal to the job number
#' (meaning that job number `N` might read and use everything stored in `list.rds`
#' at index `[[N]]`). To illustrate this concept, take for example a webscraping
#' script: `list.rds` would contain a list where each element is a character
#' vector of URLs to scrape; each job would therefore read the file but only
#' scrape `list[[N]]` so that it doesn't overlap with any other job.
#'
#' @param path Directory where to initialize kuber
#' @param cluster_name Name of the cluster where to execute jobs (must exist
#' already)
#' @param bucket_name Name of the storage bucket where the files will be stored
#' (will be created if necessary)
#' @param image_name Name of the docker image where to build the container (either
#' its full path in the form `[HOSTNAME]/[PROJECT_ID]/[IMAGE_NAME]:[VERSION]` or
#' simply `[IMAGE_NAME]` for it to be automatically pushed to the Google Cloud
#' Registry)
#'
#' @references \url{https://kubernetes.io/docs/tasks/job/parallel-processing-expansion/}
#' \url{https://cloud.google.com/container-registry/docs/quickstart}
#'
#' @return Path where the kuber folder was created
#' @export
kuber_init <- function(path, cluster_name, bucket_name, image_name) {

  # Create empty directory
  dir.create(path, showWarnings = FALSE, recursive = TRUE)
  if (length(list.files(path, all.files = TRUE, no.. = TRUE)) > 0) {
    stop("Directory must be empty")
  }

  # Hidden file for information
  file.create(paste0(path, "/.kuber"))

  # Fetch cluster info
  cl <- cluster_info(cluster_name)
  write(paste("cluster:", cluster_name), paste0(path, "/.kuber"), append = TRUE)
  write(paste("location:", cl$LOCATION), paste0(path, "/.kuber"), append = TRUE)
  write(paste("region:", gsub("-[a-z]$", "", cl$LOCATION)), paste0(path, "/.kuber"), append = TRUE)
  write(paste("num_nodes:", cl$NUM_NODES), paste0(path, "/.kuber"), append = TRUE)

  # Create bucket
  kuber_bucket(bucket_name)
  write(paste("bucket:", bucket_name), paste0(path, "/.kuber"), append = TRUE)

  # Build image name if necessary
  if (!grepl("/", image_name)) {
    conf <- gcloud_get_config(TRUE)
    project <- gsub("project = ", "", conf[grep("project = ", conf)])
    image_name <- paste0("gcr.io/", project, "/", image_name, ":latest")
  }
  write(paste("image:", image_name), paste0(path, "/.kuber"), append = TRUE)

  # Create job name
  job <- paste0("process-", paste0(sample(letters, 6, TRUE), collapse = ""))

  # Text for files
  dockerfile_file <- c(
    "FROM rocker/tidyverse",
    "RUN apt-get update -qq && apt-get -y --no-install-recommends install \\",
    "  build-essential \\",
    "  libcurl4-gnutls-dev \\",
    "  libxml2-dev \\",
    "  libssl-dev \\",
    "  r-cran-curl \\",
    "  r-cran-openssl \\",
    "  r-cran-xml2 \\",
    "  && install2.r --error \\",
    "    --deps TRUE \\",
    "    googleCloudStorageR \\",
    "    abjutils",
    'RUN wget -O ./client_id.json "https://drive.google.com/uc?id=1LETUGnNGokwPPg0Y_ViFi0uKP9vy6WF2&authuser=0&export=download"',
    'RUN wget -O ./service_account_key.json "https://drive.google.com/uc?id=1eOczW8KSGcwR7kenZaYj4EB6tatMQgL8&authuser=0&export=download"',
    "COPY exec.R list.rds* ./"
  )
  exec_r_file <- c(
    "#!/usr/bin/env Rscript",
    "args <- commandArgs(trailingOnly = TRUE)",
    "",
    "# Arguments",
    "idx <- as.numeric(args[1])",
    "bucket <- as.character(args[2])",
    "",
    "# Gcloud Authentication",
    'scopes = c("https://www.googleapis.com/auth/devstorage.read_write")',
    'googleAuthR::gar_set_client("client_id.json", scopes = scopes)',
    'googleAuthR::gar_auth_service("service_account_key.json", scope = scopes)',
    "",
    "# Use this function to save your results",
    "save_rds <- function(object, file) {",
    '  file <- gsub("\\./", "", file)',
    "  googleCloudStorageR::gcs_upload(object, bucket = bucket, name = file)",
    "}",
    "",
    "# Get object passed in list[[idx]]",
    'obj <- readRDS("list.rds")[[idx]]',
    "",
    "###########################",
    "## INSERT YOUR CODE HERE ##",
    "###########################"
  )
  job_tmpl_file <- c(
    "apiVersion: batch/v1",
    "kind: Job",
    "metadata:",
    paste0("  name: ", job, "-item-$ITEM"),
    "spec:",
    "  template:",
    "    metadata:",
    paste0("      name: ", job),
    "    spec:",
    "      containers:",
    "      - name: c",
    paste0("        image: ", image_name),
    paste0('        command: ["Rscript", "--vanilla", "exec.R", "$ITEM", "', bucket_name, '"]'),
    "      restartPolicy: OnFailure"
  )

  # Paths for files
  dockerfile <- paste0(path, "/Dockerfile")
  exec_r <- paste0(path, "/exec.R")
  job_tmpl <- paste0(path, "/job-tmpl.yaml")
  list <- paste0(path, "/list.rds")

  # Create all files
  file.create(dockerfile, exec_r, job_tmpl)
  writeLines(dockerfile_file, dockerfile)
  writeLines(exec_r_file, exec_r)
  writeLines(job_tmpl_file, job_tmpl)
  saveRDS(as.list(seq(1, 10)), list)
  dir.create(paste0(path, "/jobs"), showWarnings = FALSE, recursive = TRUE)

  # Further instructions
  todo("Edit '", exec_r, "'")
  todo("Create '", list, "' with usable parameters")
  todo("Run 'kuber_push(\\\"", path, "\\\")'")

  # Edit file
  if (requireNamespace("rstudioapi", quietly = TRUE) && is_rstudio()) {
    rstudioapi::navigateToFile(exec_r)
  }

  invisible(path)
}
