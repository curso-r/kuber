
#' Build and push a docker image
#'
#' @description Once you create a docker directory for your script with
#' [kuber_template()], this function is able to build it and push it to the
#' appropriate cloud diretory. Aditionally, it also creates all the job
#' yaml files so that the only remaining step is running the cluster
#' with [kuber_run()].
#'
#' @param path Path to the image folder
#' @param num_jobs When run, the number of jobs spawned (3 by default)
#'
#' @references \url{https://docs.docker.com/engine/reference/commandline/build/}
#' \url{https://cloud.google.com/container-registry/docs/pushing-and-pulling}
#'
#' @return The path to the template directory
#' @export
kuber_image <- function(path, num_jobs = 3L) {

  # Extract image information
  lines <- readLines(paste0(path, "/job-tmpl.yaml"))
  image <- gsub(" +image: ", "", lines[grep(" image: ", lines)])
  hostname <- gsub("/.+", "", image)

  # Build image and push it
  print_run(paste0("docker build -t ", image, " ", path))
  print_run(paste0("gcloud auth print-access-token | docker login -u oauth2accesstoken --password-stdin https://", hostname))
  print_run(paste0("docker push ", image))

  # Create individual job files
  print_run(paste0(
    "cd ", path, "; for i in $(seq ", as.integer(num_jobs),
    '); do cat job-tmpl.yaml | sed "s/\\$ITEM/$i/" > ./jobs/job-$i.yaml; done'
  ))

  return(path)
}
