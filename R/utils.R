
sys <- purrr::quietly(system)
print_run <- function(cmd) {
  message("$ ", cmd)
  sys(cmd, intern = TRUE, ignore.stderr = TRUE)$result
}

get_sudo <- function() {
  message("Enter your password for sudo privileges.")
  sys('sudo -S true', input = readline("Password: "))
}

make_flags <- function(all_flags) {
  paste(purrr::imap(all_flags, ~paste0("--", .y, " ", .x)), collapse = " ")
}

is_rstudio <- function() {
  Sys.getenv("RSTUDIO") == "1"
}
