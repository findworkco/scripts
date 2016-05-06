# Load in our dependencies
require_relative "utils/serverspec"

# Start our tests
describe "apt" do
  it "was updated within past 24 hours" do
    one_day_ago = DateTime.now() - 60 * 60 * 24
    timestamp_filepath = ENV["CI"] ? "/var/lib/apt/periodic/update-success-stamp" : "/var/cache/apt/pkgcache.bin"
    timestamp_file = file(timestamp_filepath)
    expect(timestamp_file.mtime).to(be >= one_day_ago)
  end
end
