#rails_env = ENV['RAILS_ENV'] || "production"
#rails_root = ENV['RAILS_ROOT'] || "/home/ubuntu/Projects/app"
rails_env = ENV['RAILS_ENV'] || "development"
rails_root = ENV['RAILS_ROOT'] || "/Users/sky/projects/xiaoma_tofel_admin"

#god -c god/clockwork.god -D
God.watch do |w|
   w.dir      = "#{rails_root}"
   w.name     = "sidekiq"
   w.interval = 30.seconds
   w.env      = {"RAILS_ENV" => rails_env}
   w.pid_file = '#{rails_root}/tmp/pids/sidekiq.pid'
   w.interval = 30.seconds
   w.start = "bundle exec sidekiq -C #{rails_root}/config/sidekiq.yml"
   w.stop = "sidekiqctl stop #{rails_root}/tmp/pids/sidekiq.pid 60"
   w.keepalive


  # determine the state on startup
   w.transition(:init, { true => :up, false => :start }) do |on|
  on.condition(:process_running) do |c|
    c.running = true
  end
  end

   # determine when process has finished starting
    w.transition([:start, :restart], :up) do |on|
    on.condition(:process_running) do |c|
    c.running = true
    c.interval = 5.seconds
  end

    # failsafe
     on.condition(:tries) do |c|
    c.times = 5
    c.transition = :start
    c.interval = 5.seconds
   end
  end

  # start if process is not running
   w.transition(:up, :start) do |on|
  on.condition(:process_running) do |c|
    c.running = false
  end
  end

  w.restart_if do |restart|
      restart.condition(:restart_file_touched) do |c|
        c.interval = 5.seconds
        c.restart_file = File.join(rails_root, 'tmp', 'restart.txt')
      end
  end
end