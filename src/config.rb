# Load in our dependencies
require "yaml"

# Resolve and export our local config
# http://stackoverflow.com/a/86325
filepath = "/var/find-work/scripts/index.yml"
if !File.exist?(filepath)
  abort("#{filepath} doesn't exist. " +
    "Please run `bin/install-config-{{type}}.sh` before running `bootstrap.sh`")
end
CONFIG = YAML.load_file(filepath)
