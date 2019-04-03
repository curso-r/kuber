
# Print and run command
sys <- function(txt, ..., print = TRUE, ignore.stderr = FALSE) {
  cmd <- paste0(...)

  if (!requireNamespace("callr", quietly = TRUE) || !print) {

    if (print) {
      cat("$ ", cmd, "\n")
    }
    out <- suppressWarnings(system(cmd, intern = TRUE, ignore.stderr = ignore.stderr))

  } else {

    run <- function(txt, cmd, err) {
      cat("   ", txt, sep = "")
      suppressWarnings(system2(gsub(" .+", "", cmd), gsub("^[a-z]+ ", "", cmd), stdout = TRUE, stderr = err))
    }

    err <- tempfile()
    out <- out <- callr::r(run, list(txt, cmd, err), spinner = TRUE, show = TRUE)

    grey <- crayon::make_style("#A9A9A9", grey = TRUE)
    cat(crayon::green(clisymbols::symbol$tick), "  ", grey(txt), "\n", sep = "")

    err_ <- readLines(err)
    err_ <- err_[err_ != ""]
    if (length(err_) > 0) {
      warning(err_, call. = FALSE)
    }
    file.remove(err)

  }

  return(out)
}

# Print task for user
todo <- function(txt) {
  if (!requireNamespace("callr", quietly = TRUE)) {
    cat(txt, "\n", sep = "")
  } else {
    cat(crayon::red(clisymbols::symbol$bullet), "  ", txt, "\n", sep = "")
  }
}

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
