#!/usr/bin/env ruby

# use RACK_ENV environment or default to development
ENV['RACK_ENV'] ||= 'development'

# sinatra / ruby libs, sinatra/base required for modular style
require 'sinatra/base'
require 'sinatra/reloader'
require 'sinatra/config_file'
require 'json'

# relative paths to user written libs
require_relative 'class/packet_hopr'
require_relative 'routing/routes'

# modular style app, inherits from Sinatra Base
class PacketHoprAPI < Sinatra::Base
  # register and load yaml config file
  register Sinatra::ConfigFile
  config_file 'config.yml'

  # set the root dir of the app
  set :root, settings.root

  # development, test specific settings
  configure :development, :test do
    enable :logging
    register Sinatra::Reloader

    # loaded from config.yml
    set :bind, settings.development[:bind]
    set :port, settings.development[:port]
    set :run, settings.development[:run]
    set :server, settings.development[:server]
  end

  # production specific settings
  configure :production do
    # loaded from config.yml
    set :bind, settings.production[:bind]
    set :port, settings.production[:port]
    set :run, settings.production[:run]
    set :server, settings.production[:server]
  end

  # register Routes module with Sinatra
  register Sinatra::PacketHoprAPI::Routing::Routes

  # start the server if ruby file executed directly
  run! if app_file == $0
end
