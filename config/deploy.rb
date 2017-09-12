after 'deploy:published', 'laevigata:workflow_setup'
# config valid only for current version of Capistrano
lock "3.9.0"

set :application, "laevigata"
set :repo_url, "https://github.com/curationexperts/laevigata.git"
set :deploy_to, '/opt/laevigata'

set :log_level, :debug
set :bundle_flags, '--deployment'
set :bundle_env_variables, nokogiri_use_system_libraries: 1

set :keep_releases, 5
set :passenger_restart_with_touch, true
set :assets_prefix, "#{shared_path}/public/assets"

SSHKit.config.command_map[:rake] = 'bundle exec rake'

# Default branch is :master
set :branch, ENV['REVISION'] || ENV['BRANCH_NAME'] || 'master'

append :linked_dirs, "config/emory"
append :linked_dirs, "public/assets"
append :linked_dirs, "tmp/pids"
append :linked_dirs, "tmp/cache"
append :linked_dirs, "tmp/sockets"

append :linked_files, "config/blacklight.yml"
# append :linked_files, "config/browse_everything_providers.yml" # MHB - Removed to disable browse everything functionality
append :linked_files, "config/database.yml"
append :linked_files, "config/fedora.yml"
append :linked_files, "config/redis.yml"
append :linked_files, "config/resque-pool.yml"
append :linked_files, "config/secrets.yml"
append :linked_files, "config/solr.yml"
append :linked_files, "config/honeybadger.yml"

# restart resque-pool
require 'resque'

set :resque_kill_signal, 'QUIT'

namespace :deploy do
  before :restart, 'resque:pool:stop'

  after :restart, :clear_cache do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
      # Here we can do anything such as:
      # within release_path do
      #   execute :rake, 'cache:clear'
      # end
    end
  end

  after :clear_cache, 'resque:pool:start'
end
