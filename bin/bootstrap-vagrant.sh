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

# Set up development user for PostgreSQL
# DEV: We should be using templating on `pg_hba.conf` but this is quicker/simpler for now
# DEV: Modified from https://github.com/twolfson/vagrant-nodebugme/blob/1.0.0/bin/bootstrap.sh#L26-L54
# DEV: This `if` block always runs due to Chef resetting `pg_hba.conf` content
# Grant our `vagrant` user access on the machine
pg_hba_conf_file="/etc/postgresql/9.3/main/pg_hba.conf"
postgresql_conf_file="/etc/postgresql/9.3/main/postgresql.conf"
if ! grep "vagrant" "$pg_hba_conf_file" &> /dev/null; then
  # Add CLI access
  echo "# Add Vagrant specific CLI access locally" >> "$pg_hba_conf_file"
  echo "local   all             vagrant                                 peer" >> "$pg_hba_conf_file"
  # Add host machine access (listen for host machine and allow access)
  #   Destination     Gateway         Genmask         Flags   MSS Window  irtt Iface
  #   0.0.0.0         10.0.1.1        0.0.0.0         UG        0 0          0 eth0
  #   -> 10.0.1.1
  host_ip="$(netstat --route --numeric | grep "^0.0.0.0 " | cut -d " " -f10)"
  echo "# Allow incoming connections from any IP" >> "$postgresql_conf_file"
  echo "listen_addresses = '0.0.0.0'" >> "$postgresql_conf_file"
  echo "# Add Vagrant specific access to host machine" >> "$pg_hba_conf_file"
  echo "host    all             vagrant         $host_ip/0              md5" >> "$pg_hba_conf_file"
  sudo /etc/init.d/postgresql restart 9.3
fi

# If we can't open `psql` as `vagrant`, then set up a `vagrant` user in PostgreSQL
# DEV: We must modify `pg_hba.conf` before running this command, otherwise we will be denied access
echo_command="psql --db postgres --command \"SELECT 'hai';\""
if ! sudo su vagrant --command "$echo_command" &> /dev/null; then
  create_user_command="psql --command \"CREATE ROLE vagrant WITH SUPERUSER CREATEDB LOGIN;\""
  sudo su postgres --shell /bin/bash --command "$create_user_command"
  set_user_password="psql --command \"ALTER ROLE vagrant WITH PASSWORD 'vagrant';\""
  sudo su postgres --shell /bin/bash --command "$set_user_password"
fi

# TODO: Continue to IP address setup from https://gist.github.com/twolfson/9cf0ae454be269f45af8
# TODO: Complete our new tests
# TODO: Figure out how we want to define a user for production
# TODO: Document pg_service: https://gist.github.com/twolfson/5cd240862112ef4918bd
# TODO: Restrict port tolerance for `$host_ip`

# Install development repos and scripts
if ! which git &> /dev/null; then
  sudo apt-get install -y git
fi
if ! test -d "$base_dir/app"; then
  git clone git@github.com:twolfson/find-work-app.git "$base_dir/app"
fi
if ! test -f ~vagrant/quick-start-app.sh; then
  ln -s "$base_dir/app/bin/quick-start.sh" ~vagrant/quick-start-app.sh
fi
