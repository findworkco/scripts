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

# Upload it to our host and install it
rsync -havz --chmod=0000 tmp/config/remote.yml "$target_host:remote.yml"
ssh "$target_host" ""
# Correct permissions and relocate our files
ssh "$target_host" <<EOF
# Exit upon first error and echo commands
set -e
set -x

# Correct our permissions
sudo chown root:root remote.yml
sudo chmod u=rw,g=r,o=r remote.yml

# Install our configuration
sudo mkdir -p /var/find-work/scripts
sudo chown -R root:root /var/find-work
sudo mv remote.yml /var/find-work/scripts/index.yml
EOF
