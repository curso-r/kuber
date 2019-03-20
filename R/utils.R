
sys <- purrr::quietly(system)
print_run <- function(cmd) {
  message("$ ", cmd)
  sys(cmd, intern = TRUE, ignore.stderr = TRUE)$result
}


get_sudo <- function() {
  message("Enter your password for sudo privileges.")
  sys('sudo -S true', input = readline("Password: "))
}

