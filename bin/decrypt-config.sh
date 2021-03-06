#!/usr/bin/env bash
# Taken from `findworkco/app`
# Exit on first error
set -e

# Define our secret files
secret_files="static-secrets.enc.yml"

# For each of our files in our encrypted config
for file in $secret_files; do
  # Determine src and target for our file
  src_file="config/$file"
  target_file="$(echo "config/$file" | sed -E "s/.enc.yml/.yml/")"

  # If we only want to copy, then perform a copy
  # DEV: We allow `CONFIG_COPY_ONLY` to handle tests in Wercker
  if test "$CONFIG_COPY_ONLY" = "TRUE"; then
    cp "$src_file" "$target_file"
  # Otherwise, decrypt it
  else
    sops --decrypt "$src_file" > "$target_file"
  fi
done
