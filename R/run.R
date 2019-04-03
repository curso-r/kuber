
#' Run a job on a Kubernetes cluster
#'
#' @description Given a directory with an image build via [kuber_push()], this
#' function assigns all jobs in the `/jobs` folder and runs them on the
#' associated Kubernetes cluster with the `.
#'
#' @param path Path to the kuber directory
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
#' @param path Path to the kuber directory
#'
#' @references \url{https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#get}
#'
#' @return A table with pods' status information
#' @export
kuber_pods <- function(path) {

  template <- kuber_get_config(path, "template", TRUE)
  table <- sys("Fetching pods", "kubectl get jobs -l jobgroup=", template)

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
#' @param path Path to the kuber directory
#'
#' @references \url{https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#delete}
#'
#' @return If everything has gone as expected, `TRUE`
#' @export
kuber_kill <- function(path) {
  template <- kuber_get_config(path, "template", TRUE)

  sys("Deleting jobs", "kubectl delete jobs -l jobgroup=", template)
  sys("Deleting pods", "kubectl delete pods -l jobgroup=", template)
  invisible(TRUE)
}
