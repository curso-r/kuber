
#' Build and push the docker image of a kuber directory
#'
#' @description Once you create a docker directory for your script with
#' [kuber_init()], this function is able to build it and push it to the
#' appropriate cloud diretory. Aditionally, it also creates all the job
#' yaml files so that the only remaining step is running the cluster
#' with [kuber_run()].
#'
#' @param path Path to the kuber directory
#' @param num_jobs When run, the number of jobs spawned (3 by default)
#'
#' @references \url{https://docs.docker.com/engine/reference/commandline/build/}
#' \url{https://cloud.google.com/container-registry/docs/pushing-and-pulling}
#'
#' @return Path to the kuber directory
#' @export
kuber_push <- function(path, num_jobs = 3L) {

  # Extract image information
  lines <- readLines(paste0(path, "/job-tmpl.yaml"))
  image <- gsub(" +image: ", "", lines[grep(" image: ", lines)])
  hostname <- gsub("/.+", "", image)

  # Build image and push it
  sys("docker build -t ", image, " ", path)
  sys("gcloud auth print-access-token | docker login -u oauth2accesstoken --password-stdin https://", hostname)
  sys("docker push ", image)

  # Create individual job files
  sys("cd ", path, "; rm -r jobs/*")
  sys("cd ", path, "; for i in $(seq ", as.integer(num_jobs),
      '); do cat job-tmpl.yaml | sed "s/\\$ITEM/$i/" > ./jobs/job-$i.yaml; done'
  )

  invisible(path)
}
