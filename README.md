# kuber

## Overview

`kuber` is a small toolkit that leverages [docker](https://www.docker.com/),
Google's [cloud sdk](https://cloud.google.com/sdk/) and
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
kuber::gcloud_cluster("my-cluster", num_nodes = 5)

# Create a folder with kuber's template
kuber::docker_template("my-dir", bucket_name = "my-bucket", image_name = "my-image")

# Edit the exec.R file with your script
file.edit("my-dir/exec.R")

# Replace default IDs file with your IDs
file.copy("my-ids.rds", "my-dir/ids.rds", overwrite = TRUE)

# Create a docker image from folder
kuber::docker_image("my-dir", num_jobs = 5)

# Run jobs
kuber::gcloud_run("my-dir")

# See jobs' statuses
kuber::gcloud_pods()
```

## Roadmap

- Minor 0.2.0
  - [ ] Hability to change bucket and image names
  - [ ] Functions for deleting cluster, bucket and image
  - [X] README.md
  - [ ] Better names for the functions
  - [ ] Nicer exec.R template
- Patch 0.2.1
  - [ ] Remove googleCloudStorageR from Dockerfile
- Minor 0.3.0
  - [ ] Vignette and packagedown
  - [ ] Use crayon for system calls
  - [ ] If a function fails, revert what happeded
  - [ ] User has to be able to provide their own auth
  - [ ] Documentation for auth
- Major 1.0.0
  - [ ] Automate auth creation
  - [ ] Install everything without sudo
- Major 2.0.0
  - [ ] Support for mac and windows
  - [ ] Automated testing
