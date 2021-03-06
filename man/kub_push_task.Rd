% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/push.R
\name{kub_push_task}
\alias{kub_push_task}
\title{Build and push the docker image of a kuber directory}
\usage{
kub_push_task(path, image_name = NULL, num_jobs = NULL)
}
\arguments{
\item{path}{Path to task directory (if missing, defaults to the most recently
created task)}

\item{image_name}{Name of the image where to build the container (if \code{NULL},
the default, the name of the image set by \code{\link[=kub_create_task]{kub_create_task()}})}

\item{num_jobs}{When run, the number of jobs spawned (if \code{NULL}, the default,
\code{[NUM_NODES]} of the cluster)}
}
\value{
Path to the kuber directory
}
\description{
Once you create a docker directory for your script with
\code{\link[=kub_create_task]{kub_create_task()}}, this function is able to build it and push it to the
appropriate cloud diretory. Aditionally, it also creates all the job
yaml files so that the only remaining step is running the cluster
with \code{\link[=kub_run_task]{kub_run_task()}}.
}
\references{
\url{https://docs.docker.com/engine/reference/commandline/build/}
\url{https://cloud.google.com/container-registry/docs/pushing-and-pulling}
}
