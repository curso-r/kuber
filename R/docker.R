
# Check whether current user has docker setup
#
# @description This function checks two things: if the curent user has docker
# installed (via the `which docker` shell command) and if docker can be run
# without sudo privileges (by testing the `docker info` command).
has_docker <- function() {

  # Docker is installed
  docker <- sys("", "which docker", print = FALSE)
  if (length(docker) == 0) {
    todo("Install docker with 'kub_install_docker()'")
    return(FALSE)
  }

  # User is in docker group
  group <- sys("", "docker info", print = FALSE, ignore.stderr = TRUE)
  if (length(group) == 0) {
    todo("Set user privileges with 'kub_install_docker()'")
    return(FALSE)
  }

  return(TRUE)
}

#' Install docker for the current user
#'
#' @description This function can run two routines: full docker installation
#' if the user doesn't have it or correct privilege setup if the user runs
#' docker with sudo. The first method fetches and runs the script located
#' at \url{https://get.docker.com} and the second only runs
#' `sudo usermod -aG docker $USER`. For more information, see the "Getting
#' started" vignette.
#'
#' @section Sudo:
#' To install docker, this function requires sudo privileges. To do that, it
#' prompts the user for their password and maintains it until the end of
#' execution. All commands run this way are **printed** to the console so
#' the user can know everything that's happening.
#'
#' @references \url{https://docs.docker.com/install/linux/docker-ce/ubuntu/}
#'
#' @return The path where docker was installed
#' @export
kub_install_docker <- function() {

  # Docker not installed
  docker <- sys("", "which docker", print = FALSE)
  if (length(docker) == 0) {

    # Get installation file
    get_docker <- tempfile(fileext = ".sh")
    sys("Fetching installation file", "curl -fsSL https://get.docker.com -o ", get_docker)

    # Run as sudo
    get_sudo()

    # Install and add user to docker group
    sys("Running script", "sudo sh ", get_docker)
    sys("Adding user to docker group", "sudo usermod -aG docker $USER")

    todo("Restart your session and log out for changes to take effect")
    invisible(docker)
  } else {

    # User not in docker group
    group <- sys("", "docker info", print = FALSE)
    if (length(group) == 0) {

      # Run as sudo
      get_sudo()

      # add user to docker group
      sys("Adding user to docker group", "sudo usermod -aG docker $USER")

      todo("Restart your session and log out for changes to take effect")
      invisible(docker)
    }
  }

  invisible(docker)
}
