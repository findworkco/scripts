# Load in our dependencies
require_relative "utils/serverspec"

# Start our tests
describe "NGINX" do
  it "is installed via apt" do
    expect(package("nginx")).to(be_installed())
  end

  it "is serving HTTP to everyone" do
    # Check IPv4 and IPv6
    http_port = port(80)
    expect(http_port).to(be_listening().on("0.0.0.0"))
    expect(http_port).to(be_listening().on("::"))
  end

  it "is serving HTTPS to everyone" do
    # Check IPv4 and IPv6
    https_port = port(443)
    expect(https_port).to(be_listening().on("0.0.0.0"))
    expect(https_port).to(be_listening().on("::"))
  end

  it "has proper permissions for SSL certs" do
    crt_file = file("/etc/ssl/certs/findwork.co.crt")
    expect(crt_file.mode).to(eq((USER_RWX | GROUP_RWX | OTHER_RWX).to_s(8)))
    expect(crt_file.owner).to(eq(ROOT_USER))
    expect(crt_file.group).to(eq(ROOT_GROUP))

    key_file = file("/etc/ssl/private/findwork.co.key")
    expect(key_file.mode).to(eq((USER_R | GROUP_NONE | OTHER_NONE).to_s(8)))
    expect(key_file.owner).to(eq(ROOT_USER))
    expect(key_file.group).to(eq(ROOT_GROUP))
  end

  it "has proper permissions for Diffie-Hellman group" do
    dhparam_file = file("/etc/ssl/private/dhparam.pem")
    expect(dhparam_file.mode).to(eq((USER_R | GROUP_NONE | OTHER_NONE).to_s(8)))
    expect(dhparam_file.owner).to(eq(ROOT_USER))
    expect(dhparam_file.group).to(eq(ROOT_GROUP))
  end

  it "has proper permissions for configurations" do
    # Verify only root can modify nginf.conf
    nginx_conf = file("/etc/nginx/nginx.conf")
    expect(nginx_conf.mode).to(eq((USER_RW | GROUP_R | OTHER_R).to_s(8)))
    expect(nginx_conf.owner).to(eq(ROOT_USER))
    expect(nginx_conf.group).to(eq(ROOT_GROUP))

    # Verify only root can write in conf directories
    conf_d_dir = file("/etc/nginx/conf.d")
    expect(conf_d_dir.mode).to(eq((USER_RWX | GROUP_RX | OTHER_RX).to_s(8)))
    expect(conf_d_dir.owner).to(eq(ROOT_USER))
    expect(conf_d_dir.group).to(eq(ROOT_GROUP))

    sites_available_dir = file("/etc/nginx/sites-available")
    expect(sites_available_dir.mode).to(eq((USER_RWX | GROUP_RX | OTHER_RX).to_s(8)))
    expect(sites_available_dir.owner).to(eq(ROOT_USER))
    expect(sites_available_dir.group).to(eq(ROOT_GROUP))

    # Verify permissions for our configurations
    findwork_co_conf = file("/etc/nginx/conf.d/findwork.co.conf")
    expect(findwork_co_conf.mode).to(eq((USER_RW | GROUP_R | OTHER_R).to_s(8)))
    expect(findwork_co_conf.owner).to(eq(ROOT_USER))
    expect(findwork_co_conf.group).to(eq(ROOT_GROUP))
    findwork_co_htpasswd = file("/etc/nginx/conf.d/findwork.co.htpasswd")
    expect(findwork_co_htpasswd).not_to(exist())
    localhost_conf = file("/etc/nginx/conf.d/localhost.conf")
    expect(localhost_conf.mode).to(eq((USER_RW | GROUP_R | OTHER_R).to_s(8)))
    expect(localhost_conf.owner).to(eq(ROOT_USER))
    expect(localhost_conf.group).to(eq(ROOT_GROUP))
  end

  it "has only expected configurations" do
    expect(command("ls /etc/nginx/sites-enabled").stdout).to(eq(""))
    expect(command("ls /etc/nginx/conf.d").stdout).to(eq([
      "findwork.co.conf",
      "localhost.conf",
    ].join("\n") + "\n"))
  end
end
