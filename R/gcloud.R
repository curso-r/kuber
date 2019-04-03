
#' Check whether current user has gcloud setup
#'
#' @description This function checks if the curent user has gcloud installed
#' (via the `which gcloud` shell command).
has_gcloud <- function() {
  gcloud <- sys("", "which gcloud", print = FALSE)
  if (length(gcloud) == 0) {
    return(FALSE)
  }

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
#' @references \url{https://cloud.google.com/sdk/docs/downloads-apt-get}
#'
#' @return The path where gcloud was installed
#' @export
gcloud_install <- function() {

  # Gcloud not installed
  gcloud <- sys("", "which gcloud", print = FALSE)
  if (length(gcloud) == 0) {

    # Run as sudo
    get_sudo()

    # Run installation commands
    version <- sys("", "echo $(lsb_release -c -s)", print = FALSE)
    sys("Fetching source", 'echo "deb http://packages.cloud.google.com/apt cloud-sdk-', version, ' main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list')
    sys("Adding key", "curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -")
    sys("Installing gcloud", "sudo apt-get update && sudo apt-get install -y google-cloud-sdk")
    sys("Installing kubectl", "sudo apt-get install -y kubectl")

    # Run login command
    if (is_rstudio()) {
      todo("Please run 'gcloud init' on your terminal")
    } else {
      system("gcloud init")
    }

    invisible(gcloud)
  }

  invisible(gcloud)
}
