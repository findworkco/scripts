# Load in our dependencies
require "yaml"

# Resolve and export our local config
# http://rubyforadmins.com/config-files
filepath = "/var/find-work/scripts/index.yml"
if not File.exists?(filepath)
  abort("#{filepath} doesn't exist. " +
    "Please run `bin/install-config-{{type}}.sh` before running `bootstrap.sh`")
end
CONFIG = YAML.load_file(filepath)
