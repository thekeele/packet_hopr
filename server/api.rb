#!/usr/bin/env ruby

ENV['RACK_ENV'] ||= 'development'

require 'sinatra/base'
require 'sinatra/reloader'
require 'sinatra/config_file'
require 'json'

require_relative 'class/packet_hopr'
require_relative 'routing/routes'

class PacketHoprAPI < Sinatra::Base
  register Sinatra::ConfigFile
  config_file 'config.yml'

  set :root, settings.root

  configure :development, :test do
    enable :logging
    register Sinatra::Reloader

    set :bind, settings.development[:bind]
    set :port, settings.development[:port]
    set :run, settings.development[:run]
    set :server, settings.development[:server]
  end

  configure :production do
    set :bind, settings.production[:bind]
    set :port, settings.production[:port]
    set :run, settings.production[:run]
    set :server, settings.production[:server]
  end

  register Sinatra::PacketHoprAPI::Routing::Routes

  # start the server if ruby file executed directly
  run! if app_file == $0
end
