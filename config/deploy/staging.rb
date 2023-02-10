# frozen_string_literal: true

# server-based syntax
# ======================
set :server_ip, ENV['SERVER_IP']
set :ssh_key, ENV['SSH_KEY']

set :branch, ENV['BRANCH_NAME']

# role-based syntax
# ==================

# Defines a role with one or multiple servers. The primary server in each
# group is considered to be the first unless any hosts have the primary
# property set. Specify the username and a domain or IP for the server.
# Don't use `:all`, it's a meta role.

role :app, ["#{fetch(:user)}@#{fetch(:server_ip)}"]
role :web, ["#{fetch(:user)}@#{fetch(:server_ip)}"]
role :db,  ["#{fetch(:user)}@#{fetch(:server_ip)}"]

## When Capistrano tries to delete old release, puma socket/id can be removed only by sudo user.
## Allow current user to run it with sudo priviledge.
SSHKit.config.command_map[:rm] = 'sudo rm'

# Custom SSH Options
# SSH to remote server uses username/password.
# For security reason, here uses ssh key.

server fetch(:server_ip).to_s, {
  :user => fetch(:user).to_s,
  :role => %w(app db web),
  :ssh_options => {
    :keys => fetch(:ssh_key).to_s
  }
}
