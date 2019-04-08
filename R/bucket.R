
#' Create a storage bucket
#'
#' @description This function freates a default storage bucket using the
#' `gsutil mb` command.
#'
#' @param name Name of the bucket
#'
#' @references \url{https://cloud.google.com/storage/docs/gsutil/commands/mb}
#'
#' @return The name of the bucket
#' @export
kub_create_bucket <- function(name) {
  buckets <- sys("Fetching bucket information", "gsutil ls")
  if (!any(gsub("(gs://|/)", "", buckets) == name)) {
    sys("Creating bucket", "gsutil mb gs://", name, "/")
  }
  invisible(name)
}

#' List contents of a gcloud bucket
#'
#' @description Using `gsutil ls`, this function is able to retrieve all
#' objects stored in a gclould bucket.
#'
#' @param path Path to the image folder
#' @param folder List files in which directory from the bucket
#' @param recursive Whether to list files inside folders (`FALSE` by default)
#'
#' @references \url{https://cloud.google.com/storage/docs/gsutil/commands/ls}
#'
#' @return A character vector with file names
#' @export
kub_list_bucket <- function(path, folder = "", recursive = FALSE) {
  bucket <- kub_get_config(path, "bucket", TRUE)
  if (!recursive) {
    out <- sys("Listing content", "gsutil ls gs://", bucket, "/", folder)
  } else {
    out <- sys("Listing content", "gsutil ls -r gs://", bucket, "/", folder)
  }
  gsub(paste0("gs://", bucket, "/"), "", out)
}
