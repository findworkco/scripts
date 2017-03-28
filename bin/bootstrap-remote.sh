#!/usr/bin/env bash
# Exit on first error
set -e

# Bootstrapping flags set at SSH, must be unprefixed (i.e. no LC_) in `_bootstrap.sh`

# If there is no remote server to bootstrap on, then complain and leave
target_host="$1"
if test "$target_host" = ""; then
  echo "Target host was not set. Please pass it as an argument to \`$0\`" 1>&2
  echo "Usage: $0 \"name-of-host-in-ssh-config\" <branch>" 1>&2
  exit 1
fi
branch="$2"
if test "$branch" = ""; then
  branch="master"
fi

# Output future commands
set -x

# Create a local directory for building
if test -d "tmp/build/"; then
  rm -rf tmp/build/
fi
mkdir -p tmp/build/
cd tmp/build/

# Clone our repository for a fresh start
# DEV: This is to prevent using accidentally dirty `data/`
git clone git@github.com:twolfson/find-work-scripts.git scripts
cd scripts

# Checkout the requested branch
git checkout "$branch"

# Upload our data, only allow for reads from user and nothing else from anyone
# Expanded -havz is `--human-readable --archive --verbose --compress`
base_target_dir="$(ssh "$target_host" "pwd")"
target_data_dir="$base_target_dir/data"
target_src_dir="$base_target_dir/src"
rsync --chmod u=rw,g=,o= --human-readable --archive --verbose --compress "data" "$target_host":"$base_target_data_dir"
rsync --chmod u=rw,g=,o= --human-readable --archive --verbose --compress "src" "$target_host":"$base_target_src_dir"

# Remove our sensitive files from the remote server on exit
# http://tldp.org/LDP/Bash-Beginners-Guide/html/sect_12_02.html
# DEV: This will always run whether bootstrap succeeds/fails
trap "{ ssh \"$target_host\" \"rm -rf \\\"$target_data_dir\\\"; rm -rf \\\"$target_src_dir\\\"\"; }" EXIT

# Run our bootstrap on the remote server
cat bin/_bootstrap.sh |
  LC_DATA_DIR="$target_data_dir" \
  LC_SRC_DIR="$target_src_dir" \
  ssh "$target_host"
