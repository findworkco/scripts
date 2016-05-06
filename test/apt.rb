# Load in our dependencies
require_relative "utils/serverspec"

# Start our tests
describe "apt" do
  it "has a hook to record updates" do
    hook_file = file("/etc/apt/apt.conf.d/15update-stamp")
    expect(hook_file.mode).to(eq((USER_RW | GROUP_R | OTHER_R).to_s(8)))
    expect(hook_file.owner).to(eq(ROOT_USER))
    expect(hook_file.group).to(eq(ROOT_GROUP))
  end
  it "was updated within past 24 hours" do
    one_day_ago = DateTime.now() - 60 * 60 * 24
    timestamp_file = file("/var/lib/apt/periodic/update-success-stamp")
    expect(timestamp_file.mtime).to(be >= one_day_ago)
  end
end
