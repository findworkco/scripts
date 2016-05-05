# scripts
Organizational and maintenance scripts for Find Work repositories

This repository is heavily based on [twolfson/twolfson.com-scripts][].

[twolfson/twolfson.com-scripts]: https://github.com/twolfson/twolfson.com-scripts

TODO: Remove `*travis*` files (e.g. scripts)
TODO: Rename `*twolfson*` files (e.g. scripts)
TODO: Add ratelimiter to NGINX config
TODO: Add username/password to NGINX config
TODO: Update SSH keys for `ubuntu` user

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

# Start our Vagrant instance
vagrant up

# SSH into the machine
vagrant ssh
```

## Documentation
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

## Copyright
All rights reserved, Shoulders of Titans LLC
