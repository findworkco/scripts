# Load in our dependencies
require_relative "utils/serverspec"

# Start our tests
describe "Node.js" do
  it "is installed via apt" do
    expect(package("nginx")).to(be_installed())
  end

  it "has our expected version" do
    expect(command("node --version").stdout).to(eq("v4.4.5\n"))
  end
end
