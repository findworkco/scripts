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
    postgresql_listening_address = TEST_ENV == TEST_ENV_VAGRANT ? "0.0.0.0" : "127.0.0.1"
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

  it "has only a `find_work` and `postgres` user" do
    # Define our allowed users
    # rubocop:disable Style/MutableConstant
    ALLOWED_POSTGRESQL_USERS = ["find_work", "postgres"]
    # rubocop:enable Style/MutableConstant

    # If we are in Vagrant, add our `vagrant` user
    if TEST_ENV == TEST_ENV_VAGRANT
      ALLOWED_POSTGRESQL_USERS.push("vagrant")
    end

    # Retrieve and assert our PostgreSQL users
    # DEV: This strict equality asserts that we have no extra nor are missing any users
    postgresql_users_query = "psql --command \\\"SELECT usename FROM pg_user;\\\"  --tuples --no-align"
    postgresql_users_result = command("sudo su postgres --shell /bin/bash --command \"#{postgresql_users_query}\"")
    expect(postgresql_users_result.exit_status).to(eq(0))
    postgresql_users = postgresql_users_result.stdout.split("\n")
    expect(postgresql_users.sort()).to(eq(postgresql_users.sort()))
  end

  it "has expected password for `find_work` user" do
    # Perform our login attempt
    # DEV: We use a connection URI as the CLI doesn't support password input
    #   Structure: postgres://user:password@hostname:port/database
    postgresql_uri = "postgres://find_work:find_work@127.0.0.1:5500/postgres"
    psql_login_result = command("psql \"#{postgresql_uri}\" --command \"SELECT 'hai';\"")

    # If we are in Vagrant/Wercker, verify we logged in successfully
    if [TEST_ENV_VAGRANT, TEST_ENV_WERCKER].include?(TEST_ENV)
      expect(psql_login_result.exit_status).to(eq(0))
    # Otherwise, verify we failed to login
    else
      expect(psql_login_result.exit_status).to(eq(2))
    end
  end
end
