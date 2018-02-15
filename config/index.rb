# Load in our dependencies
# Based on https://github.com/findworkco/app/blob/20170325.015012.671544694/config/index.js
require "date"
require "yaml"
require_relative "./static.rb"

# Define our constants
__DIR__ = File.dirname(__FILE__)

# Resolve our node type
NODE_TYPE = ENV["NODE_TYPE"]
if not NODE_TYPE
  abort("Environment variable \"NODE_TYPE\" wasn\'t provided. " +
    "Please provide it (e.g. NODE_TYPE=vagrant)")
end
# DEV: We use an explicit list to avoid loading `common`
if not ["vagrant", "wercker", "remote"].include?(NODE_TYPE)
  abort("Expected environment variable \"NODE_TYPE\" to be " +
    "`vagrant`, `wercker`, or `remote` but it was \"#{NODE_TYPE}\"")
end

# Resolve our git version
# http://stackoverflow.com/a/10148325
Dir.chdir(__DIR__) {
  GIT_VERSION = `git rev-parse HEAD`.strip()
  if GIT_VERSION.empty?() then raise() end
}

# Define our main function
def get_config()
  # Define meta info on our config (listed first)
  config = {
    "NODE_TYPE" => NODE_TYPE,
    "GENERATED_AT" => DateTime.now().to_s(),
    "GIT_VERSION" => GIT_VERSION,
  }

  # Perform inheritance between static items
  config = config.merge(CONFIG.fetch("common"))
  config = config.merge(CONFIG.fetch(NODE_TYPE))

  # Return our config
  return config
end

# Export our config to stdout
puts(YAML.dump(get_config()))
