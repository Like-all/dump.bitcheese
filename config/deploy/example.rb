set :scm, :git
server "dump.bitcheese.net", roles: [:web, :app, :db], user: "dump"
set :keep_releases, 03
set :rvm_type, :user

set :repo_url, "git://bitcheese.net/dump.bitcheese"
set :deploy_to, "/home/dump/dump"
set :rails_env, :production