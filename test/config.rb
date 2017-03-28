# Load in our dependencies
require_relative "utils/serverspec"

# Start our tests
describe "Config" do
  it "is installed and properly permissioned" do
    var_findworkco_dir = file("/var/find-work")
    expect(var_findworkco_dir.mode).to(eq((USER_RWX | GROUP_RX | OTHER_RX).to_s(8)))
    expect(var_findworkco_dir.owner).to(eq(ROOT_USER))
    expect(var_findworkco_dir.group).to(eq(ROOT_GROUP))

    var_findworkco_scripts_dir = file("/var/find-work/scripts")
    expect(var_findworkco_scripts_dir.mode).to(eq((USER_RWX | GROUP_RX | OTHER_RX).to_s(8)))
    expect(var_findworkco_scripts_dir.owner).to(eq(ROOT_USER))
    expect(var_findworkco_scripts_dir.group).to(eq(ROOT_GROUP))

    config_file = file("/var/find-work/scripts/index.yml")
    expect(config_file.mode).to(eq((USER_R | GROUP_NONE | OTHER_NONE).to_s(8)))
    expect(config_file.owner).to(eq(ROOT_USER))
    expect(config_file.group).to(eq(ROOT_GROUP))
  end
end
