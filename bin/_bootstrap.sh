#!/usr/bin/env bash
# Exit on first error and output commands
set -e
set -x

# Fallback data dir and src dir from `LC_*` variables
# DEV: We restrict to `LC_*` variables to prevent undesired attacks
#   http://superuser.com/a/385647
if test "$data_dir" = ""; then export data_dir="$LC_DATA_DIR"; fi
if test "$src_dir" = ""; then export src_dir="$LC_SRC_DIR"; fi

# Verify we have a data_dir and src_dir variable set
usage() {
  echo "Example: \`data_dir=\"/vagrant/data\"; src_dir=\"/vagrant/src\"; . bin/bootstrap.sh\`" 1>&2
}
if test "$data_dir" = ""; then
  echo "Environment variable \`data_dir\` wasn't set when calling \`bootstrap.sh\`." 1>&2
  echo "Please verify it is set before running it." 1>&2
  usage
  exit 1
fi
if test "$src_dir" = ""; then
  echo "Environment variable \`src_dir\` wasn't set when calling \`bootstrap.sh\`." 1>&2
  echo "Please verify it is set before running it." 1>&2
  usage
  exit 1
fi

# Install a precompiled Chef for Ubuntu
# https://downloads.chef.io/chef-client/ubuntu/
if ! which chef-client &> /dev/null ||
    test "$(chef-client --version)" != "Chef: 12.6.0"; then
  # Navigate to our tmp directory and download the Debian package
  cd /tmp
  wget https://opscode-omnibus-packages.s3.amazonaws.com/ubuntu/10.04/x86_64/chef_12.6.0-1_amd64.deb

  # Verify our SHA256 checksum and install our pacakge
  # DEV: Checksum generated by downloading file and running `sha256sum` on it
  echo "e0b42748daf55b5dab815a8ace1de06385db98e29a27ca916cb44f375ef65453 chef_12.6.0-1_amd64.deb" | sha256sum --check -
  sudo dpkg --install chef_12.6.0-1_amd64.deb
  cd -
fi

# Run our provisioner script
. src/findwork.co.sh
