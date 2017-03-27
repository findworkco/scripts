# Load in our dependencies
require "yaml"

# Load in our secrets
__DIR__ = File.dirname(__FILE__)
static_secrets = YAML.load_file("#{__DIR__}/static-secrets.yml")

# Define our generic config
CONFIG = {}

CONFIG["common"] = {
}

# DEV: We use string keys for simpler YAML files
# DEV: We don't use any nested content to limit complexity
CONFIG["vagrant"] = {
  "find_work_db_user_user" => "find_work",
  "find_work_db_user_password" => "find_work",
}

CONFIG["wercker"] = {
  "find_work_db_user_user" => CONFIG["vagrant"]["find_work_db_user_user"],
  "find_work_db_user_password" => CONFIG["vagrant"]["find_work_db_user_password"],
}

# DEV: For more remote variants, split up `remote` into more items
CONFIG["remote"] = {
  "find_work_db_user_user" => "find_work",
  "find_work_db_user_password" => static_secrets.fetch("find_work_db_user_password"),
}

# TODO: Expose Librato as well
