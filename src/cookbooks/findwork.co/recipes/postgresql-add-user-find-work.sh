#!/usr/bin/env bash
# Exit on first error and don't allow unset variables
set -e
set -u

# TODO: Heavy lifting mostly done
# TODO: Need to fix up something going wrong with SOPS decryption
#   (run the script in Vagrant for ease of access)
# TODO: Need to verify out `only_if` logic stands (run the script in Vagrant)
# TODO: Re-enable `Create our user` when we are good to go
# TODO: Verify our password works

# Fetch our user's password
user="find_work"
password="find_work"
if test "$use_sops" = "TRUE"; then
  sops_secret_filepath="$data_dir/var/sops/find-work/scripts/secret.yml"
  key='["find_work_db_user_password"]'
  sops "$sops_secret_filepath" --decrypt
  # password="$(sops "$sops_secret_filepath" --decrypt --extract '$key')"
fi
echo "$password"

# Create our user
# create_user_command="psql --command \"CREATE ROLE $user WITH CREATEDB LOGIN;\""
# sudo su postgres --shell /bin/bash --command "$create_user_command"

# Set our user's password
set_user_password="psql --command \"ALTER ROLE $user WITH PASSWORD '$password';\""
sudo su postgres --shell /bin/bash --command "$set_user_password"
