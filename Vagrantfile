# -*- mode: ruby -*-
# vi: set ft=ruby :

# Define our Vagrant configuration
Vagrant.configure(2) do |config|
  # Repair Vagrant UID/GID to match our current user
  # https://github.com/fgrehm/vagrant-lxc/issues/151
  uid = `id -u`.strip()
  gid = `id -g`.strip()
  config.vm.provision "shell", :inline => <<-EOF
    # Exit on first error
    set -e

    # Resolve our UID and GID
    src_uid="$(id -u vagrant)"
    target_uid="#{uid}"
    src_gid="$(id -g vagrant)"
    target_gid="#{gid}"

    # If the user and group ids are aligned, then exit early
    if test "$src_uid" = "$target_uid" && test "$src_gid" = "$target_gid"; then
      exit 0
    fi

    # Otherwise, update our user id and group id
    # DEV: We cannot use \`usermod\` as it complains about \`vagrant\` having a process
    # Example: UID=100; GID=101
    #  /etc/shadow: libuuid:x:100:101::/var/lib/libuuid:
    #  /etc/group: libuuid:x:101:
    sed -E "s/(vagrant:.:)$src_uid:$src_gid:/\\1$target_uid:$target_gid:/g" --in-place /etc/passwd
    sed -E "s/(vagrant:.:)$src_gid:/\\1$target_gid:/g" --in-place /etc/group

    # Update all files to the proper user and group
    find / -uid "$src_uid" 2> /dev/null | grep --invert-match -E "^(/sys|/proc)" | xargs chown "$target_uid"
    find / -gid "$src_gid" 2> /dev/null | grep --invert-match -E "^(/sys|/proc)" | xargs chgrp "$target_gid"
  EOF

  # Configure our LXC setup
  config.vm.provider "lxc" do |lxc|
    config.vm.box = "fgrehm/trusty64-lxc"
    lxc.customize("cgroup.memory.limit_in_bytes", "2048M")
  end

  # Provision our box with a script
  config.vm.provision("shell", :path => "bin/bootstrap-vagrant.sh")
end
