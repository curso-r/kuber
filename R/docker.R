
#' Check whether current user has docker setup
#'
#' @description This function checks two things: if the curent user has docker
#' installed (via the `which docker` shell command) and if docker can be run
#' without sudo privileges (by testing the `docker info` command).
has_docker <- function() {
  docker <- sys("which docker", intern = TRUE, ignore.stderr = TRUE)$result
  if (length(docker) == 0) {
    return(FALSE)
  }

  group <- sys("docker info", intern = TRUE, ignore.stderr = TRUE)$result
  if (length(group) == 0) {
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
#' `sudo usermod -aG docker $USER`.
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
docker_install <- function() {
  docker <- sys("which docker", intern = TRUE, ignore.stderr = TRUE)$result
  if (length(docker) == 0) {
    message("Downloading installation file...")
    Sys.sleep(2)

    get_docker <- tempfile(fileext = ".sh")
    print_run(paste0("curl -fsSL https://get.docker.com -o ", get_docker))

    get_sudo()

    print_run(paste0("sudo sh ", get_docker))
    print_run("sudo usermod -aG docker $USER")

    message("Restart your session and log out for changes to take effect.")
    return(docker)
  }

  group <- sys("docker info", intern = TRUE, ignore.stderr = TRUE)$result
  if (length(group) == 0) {
    message("Docker must be able to run without sudo.")

    get_sudo()

    print_run("sudo usermod -aG docker $USER")

    message("Restart your session and log out for changes to take effect.")
    return(docker)
  }

  return(docker)
}
