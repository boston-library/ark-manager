#!/bin/bash
set -e

# Remove a potentially pre-existing server.pid for Rails.
rm -f /ark-manager/tmp/pids/server.pid

# Then exec the container's main process (what's set as CMD in the Dockerfile).
exec "$@"

# based on instructions here: https://docs.docker.com/compose/rails/
