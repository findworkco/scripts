#!/usr/bin/env bash
# Exit on first error
set -e

# Resolve our environment variables
if test "$find_work_db_user_user" = ""; then
  echo "Expected environment variable \`find_work_db_user_user\` to be defined but it wasn\'t" 1>&2
  exit 1
fi

# Prepare and run our command
user="$find_work_db_user_user"
find_work_query_command="psql postgres --command \"SELECT usename FROM pg_user WHERE usename='$user';\" --tuples --no-align"
test "$(sudo su postgres --shell /bin/bash --command "$find_work_query_command")" = "$user"

