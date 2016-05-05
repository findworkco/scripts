# scripts
Organizational and maintenance scripts for Find Work repositories

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
```

## Copyright
All rights reserved, Shoulders of Titans LLC
