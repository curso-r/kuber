# kuber

## Overview

`kuber` is a small toolkit that leverages [docker](https://www.docker.com/),
Google's [cloud SDK](https://cloud.google.com/sdk/) and
[kubernetes](https://kubernetes.io/) to help you with massively parallel tasks.

## Installation

For now `kuber` can only be installed from Github:

``` r
# install.packages("devtools")
devtools::install_github("platipusc/kuber")
```

Before installing, make sure you have a [GCP](https://cloud.google.com/) project
to deploy your scripts.

## Example

A simple example of how you could use `kuber` to help you deploy a parallel task
via [expansion](https://kubernetes.io/docs/tasks/job/parallel-processing-expansion/):

``` r
# Create a kubernetes cluster
kuber::kuber_cluster("my-cluster", num_nodes = 5)

# Create a folder with kuber's template
kuber::kuber_init("my-dir", "my-bucket", "my-image")

# Edit the exec.R file with your script
file.edit("my-dir/exec.R")

# Replace default IDs file with your IDs
file.copy("my-list.rds", "my-dir/list.rds", TRUE)

# Create a docker image from folder
kuber::kuber_push("my-dir", num_jobs = 5)

# Run jobs
kuber::kuber_run("my-dir")

# See pods' statuses
kuber::kuber_pods()
```

## Roadmap

- Patch 0.2.2
  - [ ] Documentation about exec.R debugging
  - [X] Use crayon for system calls
  - [X] Add todo to user tasks
- Patch 0.2.3
  - [ ] Save relevant gcloud information in hidden file
  - [ ] gcloud container clusters get-credentials
  - [ ] Select region on kuber_run
  - [ ] Use directory in kuber_pods and _kill
- Minor 0.3.0
  - [ ] Remove googleCloudStorageR from Dockerfile
  - [ ] Functions for deleting cluster, bucket and image
  - [ ] Functions for listing other gcloud resources
  - [ ] Vignette and packagedown
  - [ ] If a function fails, revert what happeded
  - [ ] User has to be able to provide their own auth
  - [ ] Documentation for auth
  - [ ] Possibility to add project path as global option
- Major 1.0.0
  - [ ] Automate auth creation
  - [ ] Install everything without sudo
- Major 2.0.0
  - [ ] Support for mac and windows
  - [ ] Automated testing
