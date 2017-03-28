#!/usr/bin/env bash
# Exit on first error and don't allow unset variables
set -e
set -u

# Resolve our environment variables
if test "$find_work_db_user_user" = "" || test "$find_work_db_user_password" = ""; then
  echo "Expected environment variable \`find_work_db_user_user\` and \`find_work_db_user_password\` to be defined but at least one of them wasn\'t" 1>&2
  exit 1
fi

# Alias our variables for simplicity
user="$find_work_db_user_user"
password="$find_work_db_user_password"

# Create our user
create_user_command="psql --command \"CREATE ROLE $user WITH LOGIN;\""
sudo su postgres --shell /bin/bash --command "$create_user_command"

# Set our user's password
set_user_password="psql --command \"ALTER ROLE $user WITH PASSWORD '$password';\""
sudo su postgres --shell /bin/bash --command "$set_user_password"
