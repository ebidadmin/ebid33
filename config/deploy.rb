$:.unshift(File.expand_path('./lib', ENV['rvm_path'])) # Add RVM's lib directory to the load path.
require "rvm/capistrano"
require "bundler/capistrano"
set :rvm_ruby_string, '1.9.3-p0'
set :rvm_bin_path, "/usr/local/rvm/bin/"
set :domain, "106.187.49.112"
set :user, "deploy" 

set :application, "ebid"
set :repository,  "git@github.com:ebidadmin/ebid33.git"
set :scm, :git
set :use_sudo, false
set :deploy_to, "/var/www/sites/ebid.com.ph"
ssh_options[:forward_agent] = true
set :branch, "master"
set :git_shallow_clone, 1
set :git_enable_submodules, 1

role :web, "106.187.49.112"                   # Your HTTP server, Apache/etc
role :app, "106.187.49.112"                   # This may be the same as your `Web` server
role :db,  "106.187.49.112", :primary => true # This is where Rails migrations will run

set :rails_env, "production"

namespace :deploy do
  task :start do ; end
  task :stop do ; end
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
  end
end

namespace :rvm do
  task :trust_rvmrc do
    run "rvm rvmrc trust #{release_path}"
  end
end

after "deploy", "rvm:trust_rvmrc"