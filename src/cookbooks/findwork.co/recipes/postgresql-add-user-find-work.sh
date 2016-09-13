#!/usr/bin/env bash
# Exit on first error and don't allow unset variables
set -e
set -u

# TODO: Add test that we can use insecure password in Vagrant but it fails for remote

# Fetch our user's password
# DEV: We cannot run this branch inside of Vagrant due to
user="find_work"
password="find_work"
if test "$use_sops" = "TRUE"; then
  sops_secret_filepath="$data_dir/var/sops/find-work/scripts/secret.yml"
  key="[\"find_work_db_user_password\"]"
  password="$(sops "$sops_secret_filepath" --decrypt --extract "$key")"
fi
echo "$password"

# Create our user
create_user_command="psql --command \"CREATE ROLE $user WITH LOGIN;\""
sudo su postgres --shell /bin/bash --command "$create_user_command"

# Set our user's password
set_user_password="psql --command \"ALTER ROLE $user WITH PASSWORD '$password';\""
sudo su postgres --shell /bin/bash --command "$set_user_password"
