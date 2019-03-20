
has_docker <- function() {

  docker <- sys("which docker", intern = TRUE, ignore.stderr = TRUE)$result
  if (length(docker) == 0) { return(FALSE) }

  group <- sys("docker info", intern = TRUE, ignore.stderr = TRUE)$result
  if (length(group) == 0) { return(FALSE) }

  return(TRUE)
}

install_docker <- function() {

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
    return(TRUE)
  }

  group <- sys("docker info", intern = TRUE, ignore.stderr = TRUE)$result
  if (length(group) == 0) {

    message("Docker must be able to run without sudo.")

    get_sudo()

    print_run("sudo usermod -aG docker $USER")

    message("Restart your session and log out for changes to take effect.")
    return(TRUE)
  }

  return(TRUE)
}

