
#' Check whether current user has gcloud setup
#'
#' @description This function checks if the curent user has gcloud installed
#' (via the `which gcloud` shell command).
has_gcloud <- function() {

  gcloud <- sys("which gcloud", intern = TRUE, ignore.stderr = TRUE)$result
  if (length(gcloud) == 0) { return(FALSE) }

  return(TRUE)
}

#' Install gcloud for the current user
#'
#' @description This function runs the gcloud installation routine via
#' `apt-get install google-cloud-sdk`. It also installs the `kubectl`
#' package for Kubernetes functionality.
#'
#' @section Sudo:
#' To install gcloud, this function requires sudo privileges. To do that, it
#' prompts the user for their password and maintains it until the end of
#' execution. All commands run this way are **printed** to the console so
#' the user can know everything that's happening.
#'
#' @return If everything has gone as expected, `TRUE`.
#' @export
install_gcloud <- function() {

  gcloud <- sys("which gcloud", intern = TRUE, ignore.stderr = TRUE)$result
  if (length(gcloud) == 0) {

    message("Running installation process...")

    get_sudo()

    version <- system('echo $(lsb_release -c -s)', intern = TRUE)
    print_run(paste0('echo "deb http://packages.cloud.google.com/apt cloud-sdk-', version, ' main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list'))
    print_run("curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -")
    print_run("sudo apt-get update && sudo apt-get install google-cloud-sdk")
    print_run("sudo apt-get install kubectl")

    message("Login in...")
    system("gcloud init")

    return(TRUE)
  }

  return(TRUE)
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
#' @return If everything has gone as expected, `TRUE`.
#' @export
gcloud_set_config <- function(project = NULL, zone = NULL, region = NULL) {
  if (!is.null(project)) { print_run(paste0("gcloud config set project ", project)) }
  if (!is.null(zone)) { print_run(paste0("gcloud config set compute/zone ", zone)) }
  if (!is.null(region)) { print_run(paste0("gcloud config set compute/region ", region)) }

  return(TRUE)
}

#' Get gcloud configuration
#'
#' @description Prints to the console gcloud's current configuration by running
#' the `gcloud config list` command.
#'
#' @return The string vector returned by the command (invisibly).
#' @export
gcloud_get_config <- function() {
  out <- system("gcloud config list", intern = TRUE, ignore.stderr = TRUE)
  cat(out, sep = "\n")

  invisible(out)
}
