#!/usr/bin/env bash
# Exit on first error
set -e

# Define a usage function
echo_usage() {
  echo "Usage: $0 \"name-of-host-in-ssh-config\" <branch>" 1>&2
}

# If there is no remote server to bootstrap on, then complain and leave
target_host="$1"
shift
if test "$target_host" = "" || test "${target_host:0:1}" = "-"; then
  echo "Target host was not set. Please pass it as an argument to \`$0\`" 1>&2
  echo_usage
  exit 1
fi
branch="$1"
git_depth_flag=""
if test "$branch" = "" || test "${branch:0:1}" = "-"; then
  branch="master"
  git_depth_flag="--depth 1"
else
  shift
fi

# Resolve our token for Librato
librato_username="$(sops --decrypt --extract "[\"librato_username\"]" data/var/sops/find-work/scripts/secret.yml)"
librato_token="$(sops --decrypt --extract "[\"librato_token\"]" data/var/sops/find-work/scripts/secret.yml)"
if test "$librato_username" = "" || test "$librato_token" = ""; then
  echo "Unable to resolve Librato information" 1>&2
  exit 1
fi

# Output future commands
set -x

# Create a local directory for building
if test -d "tmp/build/"; then
  rm -rf tmp/build/
fi
mkdir -p tmp/build/
cd tmp/build/

# Clone our repository for a fresh start
# DEV: This is to prevent using accidentally dirty `data/`
git clone $git_depth_flag git@github.com:twolfson/find-work-app.git app
cd app

# Checkout the requested branch
git checkout "$branch"

# Find a timestamp to use for our deploy
start_time="$(date +%s)"
timestamp="$(ssh "$target_host" "date --utc +%Y%m%d.%H%M%S.%N")"
base_target_dir="/home/ubuntu/app"
target_dir="$base_target_dir/$timestamp"
main_target_dir="$base_target_dir/main"

# Tag our repository with the timestamp
git_tag="$timestamp"
git tag "$git_tag"
git push origin "$git_tag"

# Navigate back to containing folder
cd ../

# Notify Librato that our deployment has started
# https://www.librato.com/docs/api/#create-an-annotation
# {"id":287072313,"title":"Deploy 20170213.224423.773304961","description":null,"source":"unassigned","start_time":1487025855,"end_time":null,"links":[{"label":"GitHub","href":"https://github.com/twolfson/find-work-app/tree/20170213.224423.773304961","rel":"github"}]}
librato_response="$(curl \
  -u "$librato_username:$librato_token" \
  -d "title=Deploy $git_tag&start_time=$start_time" \
  -d "links[0][label]=GitHub" \
  -d "links[0][href]=https://github.com/twolfson/find-work-app/tree/$git_tag" \
  -d "links[0][rel]=github" \
  -X POST "https://metrics-api.librato.com/v1/annotations/app-deploys")"
librato_annotation_id="$(echo "$librato_response" | sed -E "s/.*\"id\":([0-9]+).*/\1/")"

# Generate a folder to upload our server to
# DEV: We use `-p` to avoid "File exists" issues
ssh "$target_host" "mkdir -p $base_target_dir"

# Upload our server files
# TODO: Consider deleting `.git`
# Expanded -havz is `--human-readable --archive --verbose --compress`
# DEV: We use trailing slashes to force uploading into non-nested directories
rsync --human-readable --archive --verbose --compress "app/" "$target_host":"$target_dir/"

# On the remote server, install our dependencies
# DEV: We perform this on the server to prevent inconsistencies between development and production
ssh -A "$target_host" "cd $target_dir && bin/deploy-install.sh"

# Replace our existing `main` server with the new one
# DEV: We use `--no-dereference` to prevent creating a symlink in the existing `main` directory
# DEV: We use a local relative target to make the symlink portable
#   ln --symbolic 20151222.073547.761299235 findwork.co/main
#   findwork.co/main -> 20151222.073547.761299235
# TODO: Add health check (verify server is running) and load balance before swap
ssh "$target_host" <<EOF
# Exit upon first error and echo commands
set -e
set -x

# Swap directories
ln --symbolic --force --no-dereference "$target_dir" "$main_target_dir"

# Restart our server and queue
sudo supervisorctl restart app-server
sudo supervisorctl restart app-queue
EOF

# Update our Librato annotation to include end time
# https://www.librato.com/docs/api/#update-an-annotation
if test "$librato_annotation_id" = ""; then
  echo "Unable to extract Librato annotation id. Skipping end time update" 1>&2
else
  end_time="$(date +%s)"
  echo "Updating Librato annotation $librato_annotation_id..." 1>&2
  curl \
    -u "$librato_username:$librato_token" \
    -d "end_time=$end_time" \
    -X PUT "https://metrics-api.librato.com/v1/annotations/app-deploys/$librato_annotation_id"
fi

# Notify the user of success
echo "Server restarted. Please manually verify the server is running at https://findwork.co/"
