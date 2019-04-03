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
library(kuber)

kuber_cluster("my-cluster")
#> ✔  Creating cluster

kuber_init("~/my-dir", "my-bucket", "my-image")
#> ✔  Creating bucket
#> ●  Edit `~/my-dir/exec.R'`
#> ●  Create `~/my-dir/list.rds` with usable objects
#> ●  Run `kuber_push(~/my-dir)'`

file.edit("my-dir/exec.R")
file.copy("my-list.rds", "my-dir/list.rds", TRUE)

kuber_push("~/my-dir")
#> ✔  Building image
#> ✔  Authenticating
#> ✔  Pushing image
#> ✔  Removing old jobs
#> ✔  Creating new jobs

kuber_run("my-dir")
#> ✔  Creating jobs
#> ●  Run `kuber_pods()` to follow up on the pods

kuber_pods()
#> ✔  Fetching pods
#>                          NAME READY  STATUS RESTARTS AGE
#> 1 process-ykwgkf-item-1-zxdbx   1/1 Running        0  2h
#> 2 process-ykwgkf-item-2-zkt4t   1/1 Running        0  2h
#> 3 process-ykwgkf-item-3-74nxj   1/1 Running        0  2h
```

## Roadmap

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
