
# Print and run command
#
# @description Using `clisymbols` and `crayon`, this function prints a pretty
# `usethis`-like step message with spinner and check-mark included.
#
# @param txt Text to print while running the command
# @param ... Command to be pasted and run
# @param print Should anything be shown to the user?
# @param ignore.stderr Whether to ignore stderr
#
# @return The result of the command as a character vector
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
#
# @description Using `clisymbols` and `crayon`, this function prints a pretty
# taks list so the user knows what's the next step.
#
# @param ... Text to be pasted and printed
todo <- function(...) {
  txt <- paste0(...)

  if (!requireNamespace("callr", quietly = TRUE)) {
    cat(txt, "\n", sep = "")
  } else {
    cmd <- crayon::cyan(paste0("`", gsub("'.*", "", gsub("^.*?'", "", txt)), "`"))
    txt <- gsub("'.+'", cmd, txt)
    cat(crayon::red(clisymbols::symbol$bullet), "  ", txt, "\n", sep = "")
  }
}
