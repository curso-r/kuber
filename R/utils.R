
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

# Change cluster context
set_context <- function(path) {
  cluster <- kub_get_config(path, "cluster", TRUE)
  contexts <- strsplit(system("kubectl config view -o jsonpath='{.contexts[*].name}'", intern = TRUE), " ")[[1]]
  context <- contexts[grepl(cluster, contexts)]
  sys("Setting cluster context", "kubectl config use-context ", context)
}

# Parse a table returned by a list command
parse_table <- function(table) {
  # Extract full table
  file <- tempfile(fileext = ".csv")
  writeLines(paste(gsub(" +", ",", table), collapse = "\n"), file)
  on.exit(file.remove(file))

  utils::read.csv(file, stringsAsFactors = FALSE)
}

# Set path as default
default_path <- function(path, set = FALSE) {

  if (missing(path)) {
    op <- options()
    if ("kuber.default_path" %in% names(op)) {
      path <- op$kuber.default_path
    } else {
      stop("Please set a default path with `options(kuber.default_path = path)`")
    }
  } else {
    if (set) {
      options(kuber.default_path = path)
    }
  }

  return(path)
}
