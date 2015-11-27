#!/bin/bash

#setup script: builds apache/mod_wsgi/libffi, creates virtualenvironment and installs python packages
dir=$(cd -P -- "$(dirname -- "$0")" && pwd -P)
sbatch $dir/jobs/job-start-aggregator