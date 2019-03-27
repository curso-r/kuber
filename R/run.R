
#' Run a job on a Kubernetes cluster
#'
#' @description Given a directory with an image build via [kuber_push()], this
#' function assigns all jobs in the `/jobs` folder and runs them on the
#' associated Kubernetes cluster with the `.
#'
#' @param path Path to the image folder
#'
#' @references \url{https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#create}
#'
#' @return The path to the kuber directory
#' @export
kuber_run <- function(path) {
  sys(paste0("cd ", path, "; kubectl create -f ./jobs"))
  cat("Run 'kuber_pods()' to follow up on the pods.\n")
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
  table <- sys("kubectl get pods")

  # Extract full table
  file <- tempfile(fileext = ".csv")
  writeLines(paste(gsub(" +", ",", table), collapse = "\n"), file)

  utils::read.csv(file)
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
  sys("kubectl delete --all jobs")
  sys("kubectl delete --all pods")
  invisible(TRUE)
}
