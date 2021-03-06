% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/run.R
\name{kub_list_pods}
\alias{kub_list_pods}
\title{Get status of current Kubernetes pods}
\usage{
kub_list_pods(path)
}
\arguments{
\item{path}{Path to task directory (if missing, defaults to the most recently
created task)}
}
\value{
A table with pods' status information
}
\description{
After running a group of jobs via \code{\link[=kub_run_task]{kub_run_task()}}, this function
runs \code{kubectl get pods} to get their statuses.
}
\references{
\url{https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#get}
}
