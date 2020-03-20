# Load DSL and set up stages
require "capistrano/setup"

# Include default deployment tasks
require "capistrano/deploy"

# Load the SCM plugin appropriate to your project:
require "capistrano/scm/git"
install_plugin Capistrano::SCM::Git

# Include tasks from other gems included in your Gemfile
#
# For documentation on these, see for example:
#
#   https://github.com/capistrano/rvm
require "capistrano/rvm"
#   https://github.com/seuros/capistrano-puma
require 'capistrano/puma'
install_plugin Capistrano::Puma
install_plugin Capistrano::Puma::Nginx
install_plugin Capistrano::Puma::Workers

# https://github.com/capistrano/npm/
require 'capistrano/npm'
#   https://github.com/capistrano/bundler
require "capistrano/bundler"
#   https://github.com/capistrano/rails
require 'capistrano/rails'

#   https://github.com/capistrano-plugins/capistrano-delayed-job
require 'capistrano/delayed_job'

# Load custom tasks from `lib/capistrano/tasks` if you have any defined
Dir.glob("lib/capistrano/tasks/*.rake").each { |r| import r }
