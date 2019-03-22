
#' Create kubernetes cluster
#'
#' @description This function creates a kubernetes cluster on the current
#' project and zone via `gcloud container clusters create`. Note that
#' the defaults values for the parameters override the defaults of the
#' shell command.
#'
#' @param name Name of the cluster
#' @param machine_type Type of the machine (`f1-micro`, `g1-small`,
#' `n1-standard-1`, etc.)
#' @param num_nodes Number of nodes on cluster (must be an integer)
#' @param disk_size Startup disk size (defaults to `20GB`)
#' @param flags List with more flags to use and their corresponding values
#'
#' @references \url{https://cloud.google.com/sdk/gcloud/reference/container/clusters/create}
#'
#' @examples
#' \dontrun{
#' create_cluster("r-cluster",
#'   disk_size = "100GB",
#'   flags = list("tags" = "k8s", "enable-autoupgrade" = "", "disk-type" = "pd-ssd")
#' )
#' }
#' 
#' @return If everything has gone as expected, `TRUE`
#' @export
gcloud_cluster <- function(name, machine_type = "g1-small", num_nodes = 3L, disk_size = "20GB", flags = list()) {
  all_flags <- c(
    list(
      "machine-type" = machine_type,
      "num-nodes" = as.integer(num_nodes),
      "disk-size" = disk_size
    ),
    flags
  )

  name <- as.character(name)
  cmd <- paste("gcloud container clusters create", name, make_flags(all_flags))

  print_run(cmd)
  return(TRUE)
}
