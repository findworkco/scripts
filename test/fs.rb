# Load in our dependencies
require_relative "utils/serverspec"

# Start our tests
describe "Filesystem" do
  it "has a folder for our application logs" do
    log_findworkco_dir = file("/var/log/findworkco")
    expect(log_findworkco_dir.mode).to(eq((USER_RWX | GROUP_RX | OTHER_RX).to_s(8)))
    expect(log_findworkco_dir.owner).to(eq(UBUNTU_USER))
    expect(log_findworkco_dir.group).to(eq(UBUNTU_GROUP))

    log_app_dir = file("/var/log/findworkco/app")
    expect(log_app_dir.mode).to(eq((USER_RWX | GROUP_RX | OTHER_RX).to_s(8)))
    expect(log_app_dir.owner).to(eq(UBUNTU_USER))
    expect(log_app_dir.group).to(eq(UBUNTU_GROUP))
  end
end
