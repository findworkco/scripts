#!/usr/bin/env bash
# Exit on first error
set -e

# Prepare and run our command
find_work_query_command="psql postgres --command \"SELECT usename FROM pg_user WHERE usename='find-work';\" --tuples --no-align"
test "$(sudo su postgres --shell /bin/bash --command "$find_work_query_command")" = "\n"

