
.onLoad <- function(libname, pkgname) {
  if (!has_docker() || !has_gcloud()) {
    warning("Environment not setup")
  }
}
