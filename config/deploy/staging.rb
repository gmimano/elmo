set :branch, 'staging'
set :ping_url, "https://staging.getelmo.org"
set :user, 'cceom'
set :home_dir, '/home/cceom'
set :use_sudo, false
set(:deploy_to) {"#{home_dir}/webapps/elmo_rails/#{stage}"}
set(:bundle_dir) {"#{home_dir}/webapps/elmo_rails/gems"}
set :default_environment, {
  "PATH" => "$HOME/bin:$HOME/webapps/elmo_rails/bin:$PATH",
  "GEM_HOME" => "$HOME/webapps/elmo_rails/gems"
}

server 'staging.getelmo.org', :app, :web, :db, :primary => true

namespace :deploy do
  %w[start stop restart].each do |command|
    desc "#{command} server"
    task command, roles: :app, except: {no_release: true} do
      run "#{home_dir}/webapps/elmo_rails/bin/#{command}"
    end
  end
end
