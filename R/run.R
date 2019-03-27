
#' Run a job on a Kubernetes cluster
#'
#' @description Given a directory with an image build via [kuber_image()], this
#' function assigns all jobs in the `/jobs` folder and runs them on the
#' associated Kubernetes cluster with the `.
#'
#' @param path Path to the image folder
#'
#' @references \url{https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#create}
#'
#' @return The path to the template directory
#' @export
kuber_run <- function(path) {
  print_run(paste0("cd ", path, "; kubectl create -f ./jobs"))
  cat("Run 'kuber_pods()' to follow up on the pods.\n")
  return(path)
}

#' Get status of current Kubernetes pods
#'
#' @description After running a group of jobs via [kuber_run()], this function
#' runs `kubectl get pods` to get their statuses.
#'
#' @references \url{https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#get}
#'
#' @export
kuber_pods <- function() {
  system("kubectl get pods")
}

#' Kill all kubernetes jobs and pods
#'
#' @description Using the command `kubectl delete`, deletes all jobs and pods
#' currently running in the cluster.
#'
#' @references \url{https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#delete}
#'
#' @return TRUE
#' @export
kuber_kill <- function() {
  print_run("kubectl delete --all jobs")
  print_run("kubectl delete --all pods")
  return(TRUE)
}
