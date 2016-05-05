# Load in our dependencies
include_recipe "common"

# Guarantee `node` is installed
# @depends_on execute[apt-get-update-periodic]
# https://github.com/nodesource/distributions/tree/96e9b7d40b6aff7ade7bc130d9e18fd140e9f4f8#installation-instructions
# DEV: Equivalent to `sudo apt-get install -y "nodejs=0.10.42-1nodesource1~trusty1"`
# DEV: We use Node.js@4.x.x for LTS https://github.com/nodejs/LTS/tree/680a181b62efe8e70b28c1f8c4c1979620b6f9d8
execute "add-nodejs-apt-repository" do
  command("curl -sL https://deb.nodesource.com/setup_4.x | sudo -E bash -")
  only_if("! which node")
end
apt_package "nodejs" do
  version("4.4.3-1nodesource1~trusty1")
  only_if("test \"$(node --version)\" != \"v4.4.3\"")
end

# Configure NGINX for `findwork.co` node
# @depends_on service[nginx]
data_file "/etc/nginx/conf.d/findwork.co.conf" do
  owner("root")
  group("root")
  mode("644") # u=rw,g=r,o=r

  # When we update, reload our NGINX
  # DEV: We have a delay to guarantee all configs reload at the same time
  notifies(:reload, "service[nginx]", :delayed)
end
data_file "/etc/nginx/nginx.conf" do
  owner("root")
  group("root")
  mode("644")
  notifies(:reload, "service[nginx]", :delayed)
end
