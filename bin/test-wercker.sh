#!/usr/bin/env bash
# Exit on first error
set -e

# Set up the backend for serverspec to run locally
export SERVERSPEC_BACKEND="exec"

# Run our tests
# TODO: Add tests for diff-based build
#   This is pending on multiple environment support in Wercker
#   https://github.com/wercker/support/issues/26
. bin/_test.sh
