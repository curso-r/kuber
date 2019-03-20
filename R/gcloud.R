
has_gcloud <- function() {

  gcloud <- sys("which gcloud", intern = TRUE, ignore.stderr = TRUE)$result
  if (length(gcloud) == 0) { return(FALSE) }

  return(TRUE)
}

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

