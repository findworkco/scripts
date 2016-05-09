#!/usr/bin/env bash
# Exit on first error and output commands
set -e
set -x

# Set up our data directory
base_dir="/vagrant"
src_data_dir="/vagrant/data"
target_data_dir="$HOME/data"

# Copy our data to a non-shared directory to prevent permissions from getting messed up
if test -d "$target_data_dir"; then
  rm -r "$target_data_dir"
fi
cp --preserve --recursive "$src_data_dir" "$target_data_dir"

# If we haven't set up SSL certificates, then generate and install them
if ! test -f /etc/ssl/certs/findwork.co.crt; then
  # Create our certificates
  # https://www.digitalocean.com/community/tutorials/openssl-essentials-working-with-ssl-certificates-private-keys-and-csrs#generate-a-self-signed-certificate
  # https://www.openssl.org/docs/manmaster/apps/req.html#EXAMPLES
  #   Country Name (2 letter code) [AU]:
  #   State or Province Name (full name) [Some-State]:
  #   Locality Name (eg, city) []:
  #   Organization Name (eg, company) [Internet Widgits Pty Ltd]:
  #   Organizational Unit Name (eg, section) []:
  #   Common Name (e.g. server FQDN or YOUR name) []:
  #   Email Address []:
  openssl_subj="/C=US/ST=Illinois/L=Chicago/O=Shoulders of Titans LLC/CN=Find Work/emailAddress=todd@findwork.co"
  openssl req \
    -newkey rsa:2048 -nodes -keyout findwork.co.key \
    -x509 -days 365 -out findwork.co.crt \
    -subj "$openssl_subj"

  # Install our certificates
  sudo mv findwork.co.crt /etc/ssl/certs/findwork.co.crt
  sudo chown root:root /etc/ssl/certs/findwork.co.crt
  sudo chmod a=rwx /etc/ssl/certs/findwork.co.crt # Anyone can do all the things

  sudo mv findwork.co.key /etc/ssl/private/findwork.co.key
  sudo chown root:root /etc/ssl/private/findwork.co.key
  sudo chmod u=r,g=,o= /etc/ssl/private/findwork.co.key # Only user can read this file
fi

# If we haven't set up a Diffie-Hellman group, then create and install it
# https://weakdh.org/sysadmin.html
if ! sudo test -f /etc/ssl/private/dhparam.pem; then
  openssl dhparam -out dhparam.pem 2048
  sudo mv dhparam.pem /etc/ssl/private/dhparam.pem
  sudo chown root:root /etc/ssl/private/dhparam.pem
  sudo chmod u=r,g=,o= /etc/ssl/private/dhparam.pem # Only user can read this file
fi

# Invoke bootstrap.sh in our context
cd "$base_dir"
data_dir="$target_data_dir"
src_dir="/vagrant/src"
. bin/_bootstrap.sh

# Install development scripts and repos
if ! which git &> /dev/null; then
  sudo apt-get install -y git
fi
if ! test -f ~vagrant/quick-start-app.sh; then
  ln -s "$base_dir/bin/quick-start-app.sh" ~vagrant/quick-start-app.sh
fi
if ! test -d "$base_dir/app"; then
  git clone git@github.com:twolfson/find-work-app.git "$base_dir/app"
fi
