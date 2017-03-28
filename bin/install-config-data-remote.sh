#!/usr/bin/env bash
# Exit on first error
set -e

# If there is no remote server to build to, then complain and leave
# DEV: We support `TARGET_HOST="my-user@127.0.0.1"` as well but that's inconsistent with `test-remote.sh`
usage_str="Usage: $0 \"name-of-host-in-ssh-config\" --secret-key \"path/to/secret.key\""
target_host="$1"
shift
if test "$target_host" = "" || test "${target_host:0:1}" = "-"; then
  echo "Target host was not set. Please pass it as an argument to \`$0\`" 1>&2
  echo "$usage_str" 1>&2
  exit 1
fi

# Output all future commands
set -x

# Generate our config
mkdir -p tmp/config
bin/decrypt-config.sh
NODE_TYPE=remote ruby config/index.rb > tmp/config/remote.yml

# TODO: Test me....

# Upload it to
ssh "$target_host" "mkdir -p /var/find-work/scripts"
rsync -havz --chmod=0000 tmp/config/remote.yml "$target_host:/var/find-work/scripts/index.yml"
ssh "$target_host" "sudo chown -R root:root /var/find-work"
ssh "$target_host" "sudo chmod u=rw,g=r,o=r /var/find-work/scripts/index.yml"
