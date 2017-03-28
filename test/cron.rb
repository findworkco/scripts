# Load in our dependencies
require_relative "utils/serverspec"

# Start our tests
describe "cron" do
  cron_daily_filepath = "/etc/cron.daily/findworkco-scripts"
  if TEST_ENV == TEST_ENV_REMOTE
    it "is installed" do
      cron_daily_file = file(cron_daily_filepath)
      expect(cron_daily_file.mode).to(eq((USER_RWX | GROUP_RX | OTHER_RX).to_s(8)))
      expect(cron_daily_file.owner).to(eq(ROOT_USER))
      expect(cron_daily_file.group).to(eq(ROOT_GROUP))
    end
  else
    it "is not installed" do
      cron_daily_file = file(cron_daily_filepath)
      expect(cron_daily_file).not_to(exist())
    end
  end
end
