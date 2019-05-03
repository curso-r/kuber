# Kuber

<!-- badges: start -->
[![CRAN status](https://www.r-pkg.org/badges/version/kuber)](https://cran.r-project.org/package=kuber)
[![Lifecycle: maturing](https://img.shields.io/badge/lifecycle-maturing-blue.svg)](https://www.tidyverse.org/lifecycle/#maturing)
<!-- badges: end -->

## Overview

Kuber is a small toolkit that leverages [docker](https://www.docker.com/),
Google's [cloud SDK](https://cloud.google.com/sdk/) and
[kubernetes](https://kubernetes.io/) to help you with massively parallel tasks.

## Installation

For now Kuber can only be installed from Github:

``` r
# install.packages("devtools")
devtools::install_github("platipusc/kuber")
```

Before installing, make sure you have a [GCP](https://cloud.google.com/) project
to deploy your scripts.

## Example

A simple example of how you could use Kuber to help you deploy a parallel task
via [expansion](https://kubernetes.io/docs/tasks/job/parallel-processing-expansion/)
is reproduced below. For a more complete guide, see the "Getting started" and
"Toy example" vignettes.

``` r
library(kuber)

kub_create_cluster("my-cluster")
#> ✔  Creating cluster

kub_create_task("~/my-dir", "my-cluster", "my-bucket", "my-image", "~/my-key.json")
#> ✔  Fetching cluster information
#> ✔  Fetching bucket information
#> ✔  Creating bucket
#> ●  Edit `~/my-dir/exec.R'`
#> ●  Create `~/my-dir/list.rds` with usable objects
#> ●  Run `kub_push_task("~/my-dir")`

file.edit("~/my-dir/exec.R")
file.copy("~/my-list.rds", "~/my-dir/list.rds", TRUE)

kub_push_task("~/my-dir")
#> ✔  Building image
#> ✔  Authenticating
#> ✔  Pushing image
#> ✔  Removing old jobs
#> ✔  Creating new jobs

kub_run_task("~/my-dir")
#> ✔  Authenticating
#> ✔  Setting cluster context
#> ✔  Creating jobs
#> ●  Run `kub_list_pods()` to follow up on the pods

kub_list_pods("~/my-dir")
#> ✔  Setting cluster context
#> ✔  Fetching pods
#>                          NAME READY  STATUS RESTARTS AGE
#> 1 process-ykwgkf-item-1-zxdbx   1/1 Running        0  2h
#> 2 process-ykwgkf-item-2-zkt4t   1/1 Running        0  2h
#> 3 process-ykwgkf-item-3-74nxj   1/1 Running        0  2h
```

## Roadmap

- Major 1.0.0
  - [ ] Automate auth creation
  - [ ] Install everything without sudo
  - [ ] If a function fails, revert what happened
- Major 2.0.0
  - [ ] Support for mac and windows
  - [ ] Automated testing
