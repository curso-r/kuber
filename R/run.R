
#' Run a job on a Kubernetes cluster
#'
#' @description Given a directory with an image build via [kub_push_task()], this
#' function assigns all jobs in the `/jobs` folder and runs them on the
#' associated Kubernetes cluster with the `.
#'
#' @param path Path to task directory (if missing, defaults to the most recently
#' created task)
#' @param cluster_name Name of the cluster where to run the jobs (if `NULL`,
#' the default, the name of the cluster set by [kub_create_task()])
#'
#' @references \url{https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#create}
#'
#' @return The path to the kuber directory
#' @export
kub_run_task <- function(path, cluster_name = NULL) {
  path <- default_path(path)

  if (is.null(cluster_name)) {
    cluster_name <- kub_get_config(path, "cluster", TRUE)
  } else {
    kub_set_config(path, list("cluster" = cluster_name))
  }

  set_context(path)
  sys("Creating jobs", "cd ", path, "; kubectl create -f ./jobs")
  todo("Run 'kub_list_pods()' to follow up on the pods")
  invisible(path)
}

#' Get status of current Kubernetes pods
#'
#' @description After running a group of jobs via [kub_run_task()], this function
#' runs `kubectl get pods` to get their statuses.
#'
#' @param path Path to task directory (if missing, defaults to the most recently
#' created task)
#'
#' @references \url{https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#get}
#'
#' @return A table with pods' status information
#' @export
kub_list_pods <- function(path) {
  path <- default_path(path)

  set_context(path)

  template <- kub_get_config(path, "template", TRUE)
  table <- sys("Fetching pods", "kubectl get pods -l jobgroup=", template)

  parse_table(table)
}

#' Kill all kubernetes jobs and pods
#'
#' @description Using the command `kubectl delete`, deletes all jobs and pods
#' currently running in the cluster.
#'
#' @param path Path to task directory (if missing, defaults to the most recently
#' created task)
#'
#' @references \url{https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#delete}
#'
#' @return If everything has gone as expected, `TRUE`
#' @export
kub_kill_task <- function(path) {
  path <- default_path(path)

  set_context(path)

  template <- kub_get_config(path, "template", TRUE)

  sys("Deleting jobs", "kubectl delete jobs -l jobgroup=", template)
  sys("Deleting pods", "kubectl delete pods -l jobgroup=", template)
  invisible(TRUE)
}

#' Get status of all currently running Kubernetes jobs
#'
#' @description This function iterates on every available kubernetes context and
#' runs `kubectl get jobs` to get the statuses of their jobs.
#'
#' @references \url{https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#get}
#'
#' @return A table with jobs' status information
#' @export
kub_list_tasks <- function() {
  tables <- data.frame()
  contexts <- strsplit(system("kubectl config view -o jsonpath='{.contexts[*].name}'", intern = TRUE), " ")[[1]]

  for (co in contexts) {
    sys("Setting cluster context", "kubectl config use-context ", co)
    table <- sys("Fetching jobs", "kubectl get jobs --all-namespaces=true")
    tables <- rbind(tables, parse_table(table))
  }

  return(tables)
}
