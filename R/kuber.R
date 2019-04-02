
.onLoad <- function(libname, pkgname) {
  if (!has_docker() || !has_gcloud()) {
    warning("Please install docker and gcloud with docker_install() and gcloud_install()")
  }
}
