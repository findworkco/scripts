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
  version("4.5.0-1nodesource1~trusty1")
  only_if("test \"$(node --version)\" != \"v4.5.0\"")
end

# Guarantee `git` is installed (required for `bower`)
apt_package("git")

# Configure NGINX for `findwork.co` node
# @depends_on service[nginx]
data_file "/etc/nginx/conf.d/findwork.co.htpasswd" do
  owner("root")
  group("root")
  mode("644") # u=rw,g=r,o=r
end
data_file "/etc/nginx/conf.d/findwork.co.conf" do
  owner("root")
  group("root")
  mode("644") # u=rw,g=r,o=r

  # When we update, reload our NGINX
  # DEV: We have a delay to guarantee all configs reload at the same time
  notifies(:reload, "service[nginx]", :delayed)
end
data_file "/etc/nginx/conf.d/localhost.conf" do
  owner("root")
  group("root")
  mode("644") # u=rw,g=r,o=r
  notifies(:reload, "service[nginx]", :delayed)
end
data_file "/etc/nginx/nginx.conf" do
  owner("root")
  group("root")
  mode("644")
  notifies(:reload, "service[nginx]", :delayed)
end

# Configure Redis for `findwork.co` node
# @depends_on apt_packages[redis-server], service[supervisord]
execute "app_redis_restart" do
  command("supervisorctl restart app-redis")
  # DEV: We don't run by default, only via `notifies` calls
  action(:nothing)
end
data_file "/etc/redis/common-redis.conf" do
  owner("root")
  group("root")
  mode("644") # u=rw,g=r,o=r

  # When we update, reload our `app-redis` instance
  # DEV: We have a delay to guarantee all configs reload at the same time
  notifies(:run, "execute[app_redis_restart]", :delayed)
end
data_file "/etc/redis/app-redis.conf" do
  owner("root")
  group("root")
  mode("644") # u=rw,g=r,o=r
  notifies(:run, "execute[app_redis_restart]", :delayed)
end

# Set up super user for our find-work-app repo
bash "add-postgresql-find-work" do
  # If the user doesn't exist yet
  find_work_query_command = "psql postgres --command \\\"SELECT usename FROM pg_user WHERE usename='find-work';\\\" --tuples --no-align"
  only_if(
    "test \"$(sudo su postgres --shell /bin/bash --command \"#{find_work_query_command}\")\" != \"\\n\"")

  # Then create our user
  code <<-EOF
    # Exit on first error and don't allow unset variables
    set -e
    set -u

    # Fetch our user's password
    password="find-work"
    if test "$use_sops" = "TRUE"; then
      sops_secret_filepath = "$data_dir/var/sops/find-work/scripts/secret.yml"
      key="["find_work_db_user_password"]"
      password="$(sops "$sops_secret_filepath" --decrypt --extract "$key")"
    fi

    # Create our user
    # create_user_command="psql --command \"CREATE ROLE vagrant WITH CREATEDB;\""
    # sudo su postgres --shell /bin/bash --command "$create_user_command"

    # Set our user's password
    # set_user_password="psql --command \"ALTER ROLE vagrant WITH PASSWORD 'vagrant';\""
    # sudo su postgres --shell /bin/bash --command "$set_user_password"
  EOF
end
