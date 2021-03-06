#!/usr/bin/env bash
# Exit on first error
set -e

# If there is no remote server to build to, then complain and leave
# DEV: We support `TARGET_HOST="my-user@127.0.0.1"` as well but that's inconsistent with `test-remote.sh`
usage_str="Usage: $0 \"name-of-host-in-ssh-config\" --dhparam \"path/to/dhparam.pem\""
target_host="$1"
shift
if test "$target_host" = "" || test "${target_host:0:1}" = "-"; then
  echo "Target host was not set. Please pass it as an argument to \`$0\`" 1>&2
  echo "$usage_str" 1>&2
  exit 1
fi

# Parse remaining arguments
# http://tldp.org/LDP/Bash-Beginners-Guide/html/sect_07_03.html
# http://superuser.com/a/541675
while true; do
  case "$1" in
    # DEV: We can dodge `&&` since we are using `set -e`
    # DEV: `dhparam` is generated via `openssl`, see `bootstrap-travis-ci.sh` for details
    --dhparam) shift; export dhparam_path="$1"; shift || break;;
    *) break;;
  esac
done

# If we don't have any inputs, then complain and leave
if test "$dhparam_path" = ""; then
  echo "Diffie-Hellman group was not set. Please pass it as an argument (\`--dhparam\`) to \`$0\`" 1>&2
  echo "$usage_str" 1>&2
  exit 1
fi

# Output all future commands
set -x

# Upload our certificates to the home directory with strict permissions
# DEV: We use 0000 to prevent our own user from reading its contents
rsync -havz --chmod=0000 "$dhparam_path" "$target_host":"dhparam.pem"

# Correct permissions and relocate our files
ssh "$target_host" <<EOF
# Exit upon first error and echo commands
set -e
set -x

# Install our new certificates
sudo chown root:root dhparam.pem
sudo chmod u=r,g=,o= dhparam.pem
sudo mv dhparam.pem /etc/ssl/private/dhparam.pem

# Reload NGINX with them
sudo /etc/init.d/nginx reload
EOF
