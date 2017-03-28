#!/usr/bin/env bash
# Exit on first error and output commands
set -e
set -x

# Set up our data directory
base_dir="$PWD"
data_dir="$base_dir/data"
src_dir="$base_dir/src"

# Decrypt our configuration automatically (done manually in other setups)
cd "$base_dir"
CONFIG_COPY_ONLY=TRUE bin/decrypt-config.sh
cd -

# Generate our configuration
if ! which git &> /dev/null; then
  sudo apt-get install -y git
fi
if ! which ruby1.9.3 &> /dev/null; then
  sudo apt-get install -y ruby1.9.3
fi
mkdir -p /var/find-work/scripts
NODE_TYPE=vagrant ruby "$base_dir/config/index.rb" > /var/find-work/scripts/index.yml
sudo chown root:root /var/find-work/scripts/index.yml
sudo chmod u=r,g=,o= /var/find-work/scripts/index.yml

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
if ! test -f /etc/ssl/private/dhparam.pem; then
  openssl dhparam -out dhparam.pem 2048
  sudo mv dhparam.pem /etc/ssl/private/dhparam.pem
  sudo chown root:root /etc/ssl/private/dhparam.pem
  sudo chmod u=r,g=,o= /etc/ssl/private/dhparam.pem # Only user can read this file
fi

# Invoke bootstrap.sh in our context
cd "$base_dir"
. bin/_bootstrap.sh
