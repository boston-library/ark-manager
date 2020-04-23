#!/bin/bash
set -e

# Remove a potentially pre-existing server.pid for Rails.
mkdir -p /ark-manager/tmp/pids

rm -f /ark-manager/tmp/pids/server.pid
rm -f /ark-manager/tmp/pids/server.state
rm -f /ark-manager/tmp/pids/puma.pid
rm -f /ark-manager/tmp/pids/puma.state
# Then exec the container's main process (what's set as CMD in the Dockerfile).
exec "$@"

# based on instructions here: https://docs.docker.com/compose/rails/
