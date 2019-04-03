
#' Build and push the docker image of a kuber directory
#'
#' @description Once you create a docker directory for your script with
#' [kuber_init()], this function is able to build it and push it to the
#' appropriate cloud diretory. Aditionally, it also creates all the job
#' yaml files so that the only remaining step is running the cluster
#' with [kuber_run()].
#'
#' @param path Path to the kuber directory
#' @param image_name Name of the image where to build the container (if `NULL`,
#' the default, the name of the image set by [kuber_init()])
#' @param num_jobs When run, the number of jobs spawned (if `NULL`, the default,
#' `[NUM_NODES]` of the cluster)
#'
#' @references \url{https://docs.docker.com/engine/reference/commandline/build/}
#' \url{https://cloud.google.com/container-registry/docs/pushing-and-pulling}
#'
#' @return Path to the kuber directory
#' @export
kuber_push <- function(path, image_name = NULL, num_jobs = NULL) {

  # Extract image information
  if (!is.null(image_name)) {
    kuber_set_config(path, list("image" = image_name))
  }
  image <- kuber_get_config(path, "image", TRUE)
  hostname <- gsub("/.+", "", image)

  # Number of jobs
  if (is.null(num_jobs)) {
    num_jobs <- as.numeric(kuber_get_config(path, "num_nodes", TRUE))
  }

  # Build image and push it
  sys("Building image", "docker build -t ", image, " ", path)
  sys("Authenticating", "gcloud auth print-access-token | docker login -u oauth2accesstoken --password-stdin https://", hostname)
  sys("Pushing image", "docker push ", image)

  # Create individual job files
  sys("Removing old jobs", "cd ", path, "; rm -r jobs/*")
  sys(
    "Creating new jobs", "cd ", path, "; for i in $(seq ", as.integer(num_jobs),
    '); do cat job-tmpl.yaml | sed "s/\\$ITEM/$i/" > ./jobs/job-$i.yaml; done'
  )

  invisible(path)
}
