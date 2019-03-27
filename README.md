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
kuber::kuber_cluster("my-cluster", num_nodes = 5)

# Create a folder with kuber's template
kuber::kuber_template("my-dir", bucket_name = "my-bucket", image_name = "my-image")

# Edit the exec.R file with your script
file.edit("my-dir/exec.R")

# Replace default IDs file with your IDs
file.copy("my-list.rds", "my-dir/list.rds", overwrite = TRUE)

# Create a docker image from folder
kuber::kuber_image("my-dir", num_jobs = 5)

# Run jobs
kuber::kuber_run("my-dir")

# See jobs' statuses
kuber::kuber_pods()
```

## Roadmap

- Minor 0.2.0
  - [X] Ability to change bucket and image names
  - [ ] Functions for deleting cluster, bucket and image
  - [X] README.md
  - [X] Better names for the functions
  - [X] Cleaner exec.R template
  - [X] ids.rds is a bad name
  - [ ] Function to list objects in bucket
  - [X] Function to kill all jobs
  - [X] Prettier output for gcloud_get_config
- Patch 0.2.1
  - [ ] Remove googleCloudStorageR from Dockerfile
  - [ ] Better dir pasting
  - [ ] Documentation about exec.R debugging
- Minor 0.3.0
  - [ ] Functions for listing other gcloud resources
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
