
#' Set gcloud configuration
#'
#' @description Sets gcloud's current project and zone configs by running
#' `gcloud config set project` and `gcloud config set compute/zone`.
#'
#' @param project The desired `[PROJECT_ID]` (or `NULL` to skip)
#' @param zone The desired `[COMPUTE_ZONE]` (or `NULL` to skip)
#' @param region The desired `[COMPUTE_REGION]` (or `NULL` to skip)
#'
#' @references \url{https://cloud.google.com/sdk/gcloud/reference/config/set}
#'
#' @return If everything has gone as expected, `TRUE`
#' @export
gcloud_set_config <- function(project = NULL, zone = NULL, region = NULL) {
  if (!is.null(project)) { print_run(paste0("gcloud config set project ", project)) }
  if (!is.null(zone)) { print_run(paste0("gcloud config set compute/zone ", zone)) }
  if (!is.null(region)) { print_run(paste0("gcloud config set compute/region ", region)) }
  return(TRUE)
}

#' Get gcloud configuration
#'
#' @description Checks gcloud's current configuration by running the
#' `gcloud config list` command.
#'
#' @references \url{https://cloud.google.com/sdk/gcloud/reference/config/list}
#'
#' @return The string vector returned by the command
#' @export
gcloud_get_config <- function() {
  out <- system("gcloud config list", intern = TRUE, ignore.stderr = TRUE)
  return(out)
}
