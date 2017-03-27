# Load in our dependencies
require "yaml"

# Load in our secrets
__DIR__ = File.dirname(__FILE__)
static_secrets = YAML.load_file("#{__DIR__}/static-secrets.yml")

# Define our generic config
CONFIG = {}

CONFIG[:common] = {
}

CONFIG[:development] = {
  :find_work_db_user_user => "find_work",
  :find_work_db_user_password => "find_work",
}

# DEV: For more production variants (e.g. different services, different nodes)
#   then define more production keys
CONFIG[:production] = {
  :find_work_db_user_user => "find_work",
  :find_work_db_user_password => static_secrets.fetch("find_work_db_user_password"),
}
