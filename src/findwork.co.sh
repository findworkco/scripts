#!/usr/bin/env bash
# Exit on first error
set -e

# Run our Chef provisioner
cd src
sudo data_dir="$data_dir" src_dir="$src_dir" chef-client --format doc --local-mode --override-runlist "recipe[findwork.co]"
