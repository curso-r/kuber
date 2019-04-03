
# Is the session running in RStudio?
is_rstudio <- function() {
  Sys.getenv("RSTUDIO") == "1"
}

# Acquire sudo privileges
get_sudo <- function() {
  if (requireNamespace("rstudioapi", quietly = TRUE) && is_rstudio()) {
    pass <- rstudioapi::askForPassword("Enter your password for sudo privileges")
    sys("", "echo ", pass, " | sudo -S true", print = FALSE)
  } else {
    cat("Enter your password for sudo privileges.\n")
    system("sudo -S true", input = readline("Password: "))
  }
}

# Create text for command flags
make_flags <- function(all_flags) {
  f <- function(a, b) {
    paste0("--", a, " ", b)
  }
  paste(mapply(f, names(all_flags), all_flags, USE.NAMES = FALSE), collapse = " ")
}
