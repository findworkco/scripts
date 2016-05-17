# Load in our dependencies
require_relative "utils/serverspec"

# Start our tests
describe "Redis" do
  it "is installed via apt" do
    expect(package("redis-server")).to(be_installed())
  end

  it "is not running its default server" do
    redis_port = port(6379)
    expect(redis_port).not_to(be_listening())
  end

  it "is listening on app-redis port" do
    app_redis_port = port(6400)
    expect(app_redis_port).to(be_listening().on("127.0.0.1"))
  end

  it "has proper permissions for configurations" do
    common_redis_conf = file("/etc/redis/common-redis.conf")
    expect(common_redis_conf.mode).to(eq((USER_RW | GROUP_R | OTHER_R).to_s(8)))
    expect(common_redis_conf.owner).to(eq(ROOT_USER))
    expect(common_redis_conf.group).to(eq(ROOT_GROUP))
    common_redis_conf = file("/etc/redis/app-redis.conf")
    expect(common_redis_conf.mode).to(eq((USER_RW | GROUP_R | OTHER_R).to_s(8)))
    expect(common_redis_conf.owner).to(eq(ROOT_USER))
    expect(common_redis_conf.group).to(eq(ROOT_GROUP))
  end
end
