#!/usr/bin/env bash
# Exit on first error and output commands
set -e
set -x

# If there is no `git` installed, then install it
if ! which git &> /dev/null; then
  sudo apt-get install -y git
fi

# Find the last commit on master
last_git_commit="$(git log master -n 1 --format=format:%H)"

# If the current commit is the same as our last commit, then find the previous one
# DEV: This occurs during `tag` on a release
current_commit="$(git rev-parse HEAD)"
if test "$current_commit" = "$last_git_commit"; then
  last_git_commit="$(git log master -n 2 --format=format:%H | grep --invert-match "$last_git_commit")"
fi

# Verify we have a commit still
if test "$last_git_commit" = ""; then
  echo "Expected \`last_git_commit\` to be defined but it was not" 1>&2
  exit 1
fi

# Checkout our last commit
git checkout "$last_git_commit"

# Always return to the previous revision, even when the past Bootstrap fails
trap "{ git checkout -; }" EXIT

# Run our provisioner
bin/bootstrap-wercker.sh

# Return to the past commit
# DEV: We will return to the past commit via `trap`
