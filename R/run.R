
#' Run a job on a Kubernetes cluster
#'
#' @description Given a directory with an image build via [docker_image()], this
#' function assigns all jobs in the `/jobs` folder and runs them on the
#' associated Kubernetes cluster with the `.
#'
#' @param path Path to the image folder
#'
#' @references \url{https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#create}
#'
#' @return If everything has gone as expected, `TRUE`
#' @export
gcloud_run <- function(path) {
  print_run(paste0("cd ", path, "; kubectl create -f ./jobs"))
  message("Run 'gcloud_jobs()' to follow up on the jobs.")
  return(TRUE)
}

#' Get status of current Kubernetes pods
#'
#' @description After running a group of jobs via [gcloud_run()], this function
#' runs `kubectl get pods` to get their statuses.
#'
#' @references \url{https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#get}
#'
#' @export
gcloud_pods <- function() {
  system("kubectl get pods")
}
