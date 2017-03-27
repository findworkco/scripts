# Load in our dependencies
require "yaml"
require_relative "./static.rb"

# Output our config to stdout
puts(YAML.dump(CONFIG))
