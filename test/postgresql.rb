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
    postgresql_port = port(5500)
    postgresql_listening_address = TEST_ENV != TEST_ENV_VAGRANT ? "0.0.0.0" : "127.0.0.1"
    expect(postgresql_port).to(be_listening().on(postgresql_listening_address))
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

  it "has only a `postgres` user" do
    # Define our allowed users
    # rubocop:disable Style/MutableConstant
    ALLOWED_POSTGRESQL_USERS = ["postgres"]
    # rubocop:enable Style/MutableConstant

    # If we are in Vagrant, add our `vagrant` user
    if TEST_ENV != TEST_ENV_VAGRANT
      ALLOWED_POSTGRESQL_USERS.push("vagrant")
    end

    # Retrieve and assert our PostgreSQL users
    postgresql_users_query = "psql --command \\\"SELECT usename FROM pg_user;\\\"  --tuples --no-align"
    postgresql_users_result = command("sudo su postgres --shell /bin/bash --command \"#{postgresql_users_query}\"")
    expect(postgresql_users_result.exit_status).to(eq(0))
    postgresql_users = postgresql_users_result.stdout.split("\n")
    expect(postgresql_users.sort()).to(eq(postgresql_users.sort()))
  end
end
