
set :thin_opt, "-C config/thin.yml"

namespace :deploy do
  desc 'Start thin server'
  task :start do
    run "cd #{current_path} && thin #{thin_opt} start"
  end

  desc 'Stop thin server'
  task :stop do
    run "cd #{current_path} && thin #{thin_opt} stop"
  end

  desc 'Restart thin server'
  task :restart do
      deploy::stop
      deploy::start
  end

end
