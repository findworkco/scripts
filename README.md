# scripts [![wercker status](https://app.wercker.com/status/425773dc85192ae3b37425708037be8e/s/master)](https://app.wercker.com/project/bykey/425773dc85192ae3b37425708037be8e)
Organizational and maintenance scripts for Find Work repositories

This repository is heavily based on [twolfson/twolfson.com-scripts][].

[twolfson/twolfson.com-scripts]: https://github.com/twolfson/twolfson.com-scripts

## Background
We maintain all of our service in a single VM via [Vagrant][]. We use [vagrant-lxc][] to get container performance while maintaining the ease of using a VM.

We choose to use [Vagrant][] over [Docker][] for a few reasons:

- [Vagrant][] shares more common knowledge with a production server (i.e. use `ssh`)
- We are more comfortable with VMs and don't want to drain time debugging Docker
    - This includes edge cases like architectural structure (e.g. placing PostgreSQl in same or separate containers, minimizing downtime on container restart)

[Vagrant]: https://www.vagrantup.com/
[vagrant-lxc]: https://github.com/fgrehm/vagrant-lxc
[Docker]: https://www.docker.com/

## Getting Started
To get our server running, perform the following steps:

- Install [Vagrant][] via its download page
    - https://www.vagrantup.com/downloads.html
- Run the following shell commands

```bash
# Clone our repository
git clone git@github.com:twolfson/find-work-scripts.git scripts
cd scripts

# Install our plugin dependencies
# https://github.com/fgrehm/vagrant-lxc/tree/v1.2.1#requirements
sudo apt-get install lxc redir

# Install our Vagrant plugin
vagrant plugin install vagrant-lxc

# Set up `sudoers` bindings for `vagrant-lxc` (avoids `sudo` for `vagrant up`/`vagrant ssh`/etc)
# https://github.com/fgrehm/vagrant-lxc/blob/v1.2.1/lib/vagrant-lxc/command/sudoers.rb
vagrant lxc sudoers

# Start our Vagrant instance
vagrant up

# SSH into the machine
vagrant ssh
```

## Documentation
### Ports
We manage our port reservations via [docs/ports.md](docs/ports.md).

If you are registering a new service, please update the document via a pull request.

### File structure
This repository has the following file structure:

- `.bundle/` - Configuration for Bundler (used for managing Ruby gems)
- `bin/` - Contains our executable files (e.g. deployment scripts)
- `data/` - Contains static files used during provisioning
    - This starts at `/` as if it were the root of a file system
    - For multiple environment projects, it's good to have a `data/{{env}}` for each setup (e.g. `data/development`, `data/production`)
- `src/` - Container for our bootstrapping scripts
- `test/` - Container for our test files
- `README.md` - Documentation for this repository
- `Vagrantfile` - Configuration for Vagrant

### Provisioning a new server
To provision a new server via [Digital Ocean][], follow the steps below:

- If we don't have a Digital Ocean SSH key pair yet, then generate one
    - https://help.github.com/articles/generating-ssh-keys/
- Create a new Ubuntu based droplet with our SSH key (14.04 x64)
- Add public key to [data/home/ubuntu/.ssh/authorized_keys][] so we can `ssh` into the `ubuntu` user
    - Digital Ocean's SSH key will initially be registered to `root` user but we dislike having direct SSH access into a `root` user
- Once droplet has started, set up our `~/.ssh/config` on the local machine

```
# Replace `digital-my-server` with a better name
# Replace 127.0.0.1 with droplet's public IP
Host digital-my-server
    User root
    HostName 127.0.0.1
```

- Install our SSL certificates and Diffie-Hellman group to the server
    - `bin/install-nginx-data-remote.sh digital-my-server --crt path/to/my-domain.crt --key path/to/my-domain.key --dhparam path/to/dhparam.pem`
    - If you are trying to get a replica working (e.g. don't have these certificates), then self-signed certificates and a `dhparam.pem` can be generated via the `openssl` commands in `bin/bootstrap-vagrant.sh`
- Install our PGP private key to the server
    - `bin/install-pgp-data-remote.sh digital-my-server --secret-key path/to/private.rsa`
    - If you don't have the `private.rsa` file on hand, it can be dumped via
        - Find full fingerprint of key we want to export
            - `gpg --fingerprint`
            - Fingerprint will be `740D DBFA...` in `Key fingerprint = 740D DBFA...`
        - Extract private key to file
            - `gpg --export-secret-keys --armor {{fingerprint}} > private.rsa`
            - `--armor` exports a human-friendly ASCII format instead of binary
    - If you are trying to get a replica working (e.g. don't have these certificates), then a key can be generated via these instructions
        - https://gist.github.com/twolfson/01d515258eef8bdbda4f#setting-up-sops-with-pgp
- Bootstrap our server
    - `bin/bootstrap-remote.sh digital-my-server`
- Update `~/.ssh/config` to use `User ubuntu` instead of `User root`
    - During the bootstrap process, we intentionally lock our `root` access via `ssh` for security
- Run our tests on the server
    - `bin/test-remote.sh digital-my-server`
- Add swap space to the server (necessary for memory-intensive installs)
    - https://www.digitalocean.com/community/tutorials/how-to-add-swap-on-ubuntu-14-04
    - On a 1GB Digial Ocean instance, we use:
        - `sudo dd if=/dev/zero of=/swapfile bs=512M count=4`
        - `sudo chmod 600 /swapfile`
        - `sudo mkswap /swapfile`
        - `sudo nano /etc/fstab`
        - `sudo sysctl vm.swappiness=10`
        - `sudo nano /etc/sysctl.conf`
        - `sudo sysctl vm.vfs_cache_pressure=50`
        - `sudo nano /etc/sysctl.conf`
- Install Librato via https://metrics.librato.com/integrations
    - Instead of using `curl | sudo bash`. Download the script via `wget`, verify it looks good via `less`, and run it via `sudo ./{{script-name}}`

[Digital Ocean]: http://digitalocean.com/
[data/home/ubuntu/.ssh/authorized_keys]: data/home/ubuntu/.ssh/authorized_keys

### Updating a server configuration
We reuse our provisioning script for managing server state. As a result, we can reuse it for updates:

```bash
bin/bootstrap-remote.sh digital-my-server

# If we need to use a non-master ref, then pass it as a second parameter
# bin/bootstrap-remote.com.sh digital-my-server dev/new.feature
```

### Deploying a service
To deploy a service, use its respective `bin/deploy-*.sh` script. Here's an example with `find-work-app`:

```bash
bin/deploy-app.sh digital-my-server

# If we need to deploy a non-master ref, then pass as a second parameter
# bin/deploy-app.sh digital-my-server dev/new.feature
```

### Editing secrets
We maintain a set of secrets (e.g. passwords) for provisioning in production in `data/var/sops/find-work/scripts`. To edit these files locally, perform the following steps:

- Install SOPS' dependencies as specified by https://github.com/mozilla/sops/tree/0494bc41911bc6e050ddd8a5da2bbb071a79a5b7#up-and-running-in-60-seconds
- Install our consistent patched SOPS version
    - `pip install --upgrade git+https://github.com/twolfson/sops.git@b8ce8fb#egg=sops`
    - TODO: We can move back to a normal SOPS when https://github.com/mozilla/sops/pull/120 is landed
- Ask a coworker for the `find-work-scripts` PGP private key
    - We assume you will receive it as `private.rsa`
    - For coworkers, see the Provisioning a new server section for dump commands
- Install the `find-work-scripts` PGP private key to GPG
    - `gpg --import private.rsa`
- Edit the SOPS file
    - `sops data/var/sops/find-work/scripts/secret.yml`

If you would like to learn more about PGP and SOPS, @twolfson has prepared this document:

https://gist.github.com/twolfson/01d515258eef8bdbda4f

### Security
We try to keep our services as secure as possible via the following means:

- Restricting shell access for SSH users
- Preventing password only authentication for SSH
- Restricting permissions on sensitive files (e.g. SSL certificates, NGINX configurations)

#### Patched major CVE's
We have gone out of our way to patch the following CVE's:

- [x] Shellshock - Patched by upgrading bash (default is fine on Ubuntu 14.04)
    - http://krebsonsecurity.com/2014/09/shellshock-bug-spells-trouble-for-web-security/
- [x] Heartbleed - Patched by upgrading NGINX (default is fine on Ubuntu 14.04)
    - http://heartbleed.com/
- [x] POODLE - Patched by restricting SSL methods used by NGINX
    - https://access.redhat.com/articles/1232123
    - https://cipherli.st/
- [x] Logjam - Patched by using new Diffie-Hellman group
    - https://weakdh.org/sysadmin.html

### Testing
We use [Serverspec][] for testing local and remote servers. This is a [Ruby][] gem so you will need it installed to run our tests:

```bash
# Install bundler to manage gems for local directory
gem install bundler

# Install dependencies for this repo
bundle install

# Run our tests
./test.sh
```

To make iterating on our test suite faster, we have set up `SKIP_LINT` and `SKIP_PROVISION` environment variables. This skips running linting and `vagrant provision` in our tests:

```bash
# Skip both linting and provisioning
SKIP_LINT=TRUE SKIP_PROVISION=TRUE ./test.sh
```

[Ruby]: https://www.ruby-lang.org/en/

### Validating production
To run our test suite against a production machine, we can use the `bin/test-remote.sh` script.

```bash
bin/test-remote.sh digital-my-server
```

## Copyright
All rights reserved, Shoulders of Titans LLC
