#!/usr/bin/env bash
# Exit on first error and don't allow unset variables
set -e
set -u

# Fetch our user's password
password="find-work"
if test "$use_sops" = "TRUE"; then
  sops_secret_filepath = "$data_dir/var/sops/find-work/scripts/secret.yml"
  key="["find_work_db_user_password"]"
  password="$(sops "$sops_secret_filepath" --decrypt --extract "$key")"
fi

# Create our user
# create_user_command="psql --command \"CREATE ROLE vagrant WITH CREATEDB;\""
# sudo su postgres --shell /bin/bash --command "$create_user_command"

# Set our user's password
# set_user_password="psql --command \"ALTER ROLE vagrant WITH PASSWORD 'vagrant';\""
# sudo su postgres --shell /bin/bash --command "$set_user_password"
