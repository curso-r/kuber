
# Run system commands quietly
sys <- purrr::quietly(system)

# Print and run command
print_run <- function(cmd) {
  message("$ ", cmd)
  sys(cmd, intern = TRUE, ignore.stderr = TRUE)$result
}

# Acquire sudo privileges
get_sudo <- function() {
  message("Enter your password for sudo privileges.")
  sys("sudo -S true", input = readline("Password: "))
}

# Create text for command flags
make_flags <- function(all_flags) {
  paste(purrr::imap(all_flags, ~ paste0("--", .y, " ", .x)), collapse = " ")
}

# Is the session running in RStudio?
is_rstudio <- function() {
  Sys.getenv("RSTUDIO") == "1"
}
