#!/usr/bin/env bash
# DEV: We skip `set -e` as we are executing this via `.`
# Navigate to the repo directory
cd /vagrant/app

# Run its start script
ENV=development ./start.sh
