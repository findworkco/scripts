# Load in our dependencies
require_relative "utils/serverspec"

# Start our tests
describe "PostgreSQL 9.3" do
  it "is installed via apt" do
    expect(package("postgresql-9.3")).to(be_installed())
  end

  it "is not running on its default port" do
    redis_port = port(5432)
    expect(redis_port).not_to(be_listening())
  end

  it "is listening on our custom port" do
    app_redis_port = port(5500)
    expect(app_redis_port).to(be_listening().on("127.0.0.1"))
  end

  it "has proper permissions for configurations" do
    pg_hba_conf = file("/etc/postgresql/9.3/main/pg_hba.conf")
    expect(pg_hba_conf.mode).to(eq((USER_RW | GROUP_R | OTHER_NONE).to_s(8)))
    expect(pg_hba_conf.owner).to(eq(POSTGRES_USER))
    expect(pg_hba_conf.group).to(eq(POSTGRES_GROUP))
    postgresql_conf = file("/etc/postgresql/9.3/main/postgresql.conf")
    expect(postgresql_conf.mode).to(eq((USER_RW | GROUP_R | OTHER_R).to_s(8)))
    expect(postgresql_conf.owner).to(eq(POSTGRES_USER))
    expect(postgresql_conf.group).to(eq(POSTGRES_GROUP))
  end
end
