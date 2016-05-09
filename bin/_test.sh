#!/usr/bin/env bash
# Exit on first error
set -e

# If we should lint our files, then run our linter
# DEV: We manually specify files to skip linting `app/`
if test "$SKIP_LINT" != "TRUE"; then
  bin/rubocop Gemfile Vagrantfile bin/ data/ docs/ src/ test/
fi

# Run our rspec tests (depends on SSH_CONFIG, TARGET_HOST)
bin/rspec --color test/*.rb
