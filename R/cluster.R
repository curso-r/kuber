
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
#' @return The name of the cluster
#' @export
kuber_cluster <- function(name, machine_type = "g1-small", num_nodes = 3L, disk_size = "20GB", flags = list()) {

  # Create list with all flags for the command
  all_flags <- c(
    list(
      "machine-type" = machine_type,
      "num-nodes" = as.integer(num_nodes),
      "disk-size" = disk_size
    ),
    flags
  )

  # Build and run command
  name <- as.character(name)
  cmd <- paste("gcloud container clusters create", name, make_flags(all_flags))
  sys("Creating cluster", cmd)

  invisible(name)
}

#' Fetch cluster information
#'
#' @description This function returns the row of information about a cluster
#' named `name_cluster` from the results in `gcloud container clusters list`.
#'
#' @param cluster_name Name of the cluster (must exist)
cluster_info <- function(cluster_name) {
  table <- sys("Fetching cluster information", "gcloud container clusters list")

  # Extract full table
  file <- tempfile(fileext = ".csv")
  writeLines(paste(gsub(" +", ",", table), collapse = "\n"), file)
  on.exit(file.remove(file))

  # Get corresponding row
  table <- utils::read.csv(file, stringsAsFactors = FALSE)
  id <- which(table$NAME == cluster_name)


  if (length(id) == 0) {
    stop("Cluster must exist")
  }
  return(table[id, ])
}
