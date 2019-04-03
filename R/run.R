
#' Run a job on a Kubernetes cluster
#'
#' @description Given a directory with an image build via [kuber_push()], this
#' function assigns all jobs in the `/jobs` folder and runs them on the
#' associated Kubernetes cluster with the `.
#'
#' @param path Path to the image folder
#' @param cluster_name Name of the cluster where to run the jobs (if `NULL`,
#' the default, the name of the cluster set by [kuber_init()])
#'
#' @references \url{https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#create}
#'
#' @return The path to the kuber directory
#' @export
kuber_run <- function(path, cluster_name = NULL) {

  if (is.null(cluster_name)) {
    cluster_name <- kuber_get_config(path, "cluster", TRUE)
  } else {
    kuber_set_config(path, list("cluster" = cluster_name))
  }

  suppressWarnings(sys("Authenticating", "gcloud container clusters get-credentials ", cluster_name))
  sys("Setting cluster configuration", "kubectl config set-cluster ", cluster_name)
  sys("Creating jobs", "cd ", path, "; kubectl create -f ./jobs")
  todo("Run 'kuber_pods()' to follow up on the pods")
  invisible(path)
}

#' Get status of current Kubernetes pods
#'
#' @description After running a group of jobs via [kuber_run()], this function
#' runs `kubectl get pods` to get their statuses.
#'
#' @references \url{https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#get}
#'
#' @return A table with pods' status information
#' @export
kuber_pods <- function() {
  table <- sys("Fetching pods", "kubectl get pods")

  # Extract full table
  file <- tempfile(fileext = ".csv")
  writeLines(paste(gsub(" +", ",", table), collapse = "\n"), file)
  on.exit(file.remove(file))

  utils::read.csv(file, stringsAsFactors = FALSE)
}

#' Kill all kubernetes jobs and pods
#'
#' @description Using the command `kubectl delete`, deletes all jobs and pods
#' currently running in the cluster.
#'
#' @references \url{https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#delete}
#'
#' @return If everything has gone as expected, `TRUE`
#' @export
kuber_kill <- function() {
  sys("Deleting jobs", "kubectl delete --all jobs")
  sys("Deleting pods", "kubectl delete --all pods")
  invisible(TRUE)
}
