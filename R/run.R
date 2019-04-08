
#' Run a job on a Kubernetes cluster
#'
#' @description Given a directory with an image build via [kub_push_task()], this
#' function assigns all jobs in the `/jobs` folder and runs them on the
#' associated Kubernetes cluster with the `.
#'
#' @param path Path to the kuber directory
#' @param cluster_name Name of the cluster where to run the jobs (if `NULL`,
#' the default, the name of the cluster set by [kub_init_task()])
#'
#' @references \url{https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#create}
#'
#' @return The path to the kuber directory
#' @export
kub_run_task <- function(path, cluster_name = NULL) {
  if (is.null(cluster_name)) {
    cluster_name <- kub_get_config(path, "cluster", TRUE)
  } else {
    kub_set_config(path, list("cluster" = cluster_name))
  }

  suppressWarnings(sys("Authenticating", "gcloud container clusters get-credentials ", cluster_name))
  contexts <- strsplit(system("kubectl config view -o jsonpath='{.contexts[*].name}'", intern = TRUE), " ")[[1]]
  context <- contexts[grepl(cluster_name, contexts)]
  sys("Setting cluster context", "kubectl config use-context ", context)
  sys("Creating jobs", "cd ", path, "; kubectl create -f ./jobs")
  todo("Run 'kub_list_pods()' to follow up on the pods")
  invisible(path)
}

#' Get status of current Kubernetes pods
#'
#' @description After running a group of jobs via [kub_run_task()], this function
#' runs `kubectl get pods` to get their statuses.
#'
#' @param path Path to the kuber directory
#'
#' @references \url{https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#get}
#'
#' @return A table with pods' status information
#' @export
kub_list_pods <- function(path) {

  cluster <- kub_get_config(path, "cluster", TRUE)
  contexts <- strsplit(system("kubectl config view -o jsonpath='{.contexts[*].name}'", intern = TRUE), " ")[[1]]
  context <- contexts[grepl(cluster, contexts)]
  sys("Setting cluster context", "kubectl config use-context ", context)

  template <- kub_get_config(path, "template", TRUE)
  table <- sys("Fetching pods", "kubectl get pods -l jobgroup=", template)

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
kub_kill_task <- function(path) {

  cluster <- kub_get_config(path, "cluster", TRUE)
  contexts <- strsplit(system("kubectl config view -o jsonpath='{.contexts[*].name}'", intern = TRUE), " ")[[1]]
  context <- contexts[grepl(cluster, contexts)]
  sys("Setting cluster context", "kubectl config use-context ", context)

  template <- kub_get_config(path, "template", TRUE)

  sys("Deleting jobs", "kubectl delete jobs -l jobgroup=", template)
  sys("Deleting pods", "kubectl delete pods -l jobgroup=", template)
  invisible(TRUE)
}
