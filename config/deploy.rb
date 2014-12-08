# config valid only for Capistrano 3.1
lock '3.2.1'

set :application, 'xiaoma_tofel_admin'
set :repo_url, 'git@github.com:skyyuan/xiaoma_tofel_admin.git'

# Default branch is :master
# ask :branch, proc { `git rev-parse --abbrev-ref HEAD`.chomp }.call

# Default deploy_to directory is /var/www/my_app
#development
# set :deploy_to, '/home/xiaomaxl/xiaoma_tofel_admin'
#production
#set :deploy_to, '/home/xmtf/xiaoma_tofel_admin'

# set :pty, false

# Default value for :scm is :git
# set :scm, :git

# Default value for :format is :pretty
# set :format, :pretty

# Default value for :log_level is :debug
# set :log_level, :debug

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
set :linked_files, %w{config/database.yml}

# Default value for linked_dirs is []
set :linked_dirs, %w{bin log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system}

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
# set :keep_releases, 5

namespace :deploy do
  # task :start do
  #   on roles(:app), in: :sequence, wait: 5 do
  #     execute "god -c #{deploy_to}/current/config/sidekiq.god -D"
  #     # execute "god load #{deploy_to}/current/config/sidekiq.god"
  #   end
  # end
  task :stop do ; end
  desc 'Restart application'
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      # Your restart mechanism here, for example:
      # execute :touch, release_path.join('tmp/restart.txt')
      execute "god restart sidekiq"
    end
  end
  # after 'deploy:starting', :start
  after :publishing, :restart

  after :restart, :clear_cache do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
      # Here we can do anything such as:
      # within release_path do
      #   execute :rake, 'cache:clear'
      # end
    end
  end

end
