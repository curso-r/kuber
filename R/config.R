
#' Get gcloud configuration
#'
#' @description Checks gcloud's current configuration by running the
#' `gcloud config list` command.
#'
#' @param quiet Whether to skip printing output (`FALSE` by default)
#'
#' @references \url{https://cloud.google.com/sdk/gcloud/reference/config/list}
#'
#' @return The string vector returned by the command
#' @export
gcloud_get_config <- function(quiet = FALSE) {
  out <- sys("", "gcloud config list", print = FALSE, ignore.stderr = TRUE)
  if (!quiet) {
    cat(out, sep = "\n")
  }
  invisible(out)
}

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
  if (!is.null(project)) {
    sys("Setting project", "gcloud config set project ", project)
  }
  if (!is.null(zone)) {
    sys("Setting zone", "gcloud config set compute/zone ", zone)
  }
  if (!is.null(region)) {
    sys("Setting region", "gcloud config set compute/region ", region)
  }
  invisible(TRUE)
}

#' Get bucket and image information from a kuber folder
#'
#' @description This function extracts the names of all important kuber
#' parameters stored in the `.kuber` hidden file.
#'
#' @param path Path to the kuber directory
#' @param what What parameter to return: `all`, `cluster`, `location`,
#' `region`, `num_nodes`, `bucket`, or `image`
#' @param quiet Whether to skip printing output (`FALSE` by default)
#'
#' @return A character vector with each parameter
#' @export
kuber_get_config <- function(path, what = "all", quiet = FALSE) {

  # Extract information
  lines <- readLines(paste0(path, "/.kuber"))

  # Get chosen parameter
  if (what != "all") {
    lines <- gsub(paste0(what, ": "), "", lines[grepl(what, lines)])
  }

  if (!quiet) {
    cat(lines, sep = "\n")
  }
  invisible(lines)
}

#' Set bucket and image information in a kuber directory
#'
#' @description This function sets the names of the docker image and of the
#' gcloud bucket in `job-tmpl.yaml` at a kuber folder.
#'
#' @param path Path to the kuber directory
#' @param bucket_name Desired bucket name (or `NULL` to skip)
#' @param image_name Desired image name (or `NULL` to skip)
#'
#' @return If everything has gone as expected, `TRUE`
#' @export
kuber_set_config <- function(path, bucket_name = NULL, image_name = NULL) {

  # Build image name if necessary
  if (!grepl("/", image_name)) {
    conf <- gcloud_get_config(TRUE)
    project <- gsub("project = ", "", conf[grep("project = ", conf)])
    image_name <- paste0("gcr.io/", project, "/", image_name, ":latest")
  }

  # Change settings
  lines <- readLines(paste0(path, "/job-tmpl.yaml"))
  if (!is.null(bucket_name)) {
    lines[grep(" command: ", lines)] <- gsub(
      'ITEM", ".+"]', paste0('ITEM", "', bucket_name, '"]'),
      lines[grep(" command: ", lines)]
    )
  }
  if (!is.null(image_name)) {
    lines[grep(" image: ", lines)] <- gsub(
      ": .+", paste0(": ", image_name),
      lines[grep(" image: ", lines)]
    )
  }

  # Write file
  writeLines(lines, paste0(path, "/job-tmpl.yaml"))

  todo("To apply changes, run 'kuber_push()'")
  invisible(TRUE)
}
