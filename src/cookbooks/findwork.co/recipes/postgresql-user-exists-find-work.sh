#!/usr/bin/env bash
# Exit on first error
set -e

# Prepare and run our command
user="find_work"
find_work_query_command="psql postgres --command \"SELECT usename FROM pg_user WHERE usename='$user';\" --tuples --no-align"
test "$(sudo su postgres --shell /bin/bash --command "$find_work_query_command")" = "$user"

