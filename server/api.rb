#!/usr/bin/env ruby

require 'sinatra/base'
require 'sinatra/reloader'
require 'json'
require_relative 'packet_hopr'

class PacketHoprAPI < Sinatra::Base

  set :bind, '192.168.1.36'
  set :port, '8000'

  configure :development, :test do
    enable :logging
    register Sinatra::Reloader
  end

  before do
    content_type :json

    if request.path_info.count('/') > 1
      redirect '/error'
    end
  end

  get '/' do
    JSON.pretty_generate({key: 'Welcome to PacketHopr', value: 'add /DOMAIN_NAME to see your path'})
  end

  get '/:domain' do
    domain = params[:domain]
    regex = /^[a-zA-Z0-9][a-zA-Z0-9\-_]{0,61}[a-zA-Z0-9]{0,1}\.([a-zA-Z]{1,6}|[a-zA-Z0-9\-]{1,30}\.[a-zA-Z]{2,3})$/

    if regex.match(domain).nil?
      JSON.pretty_generate({key: 'Uh Oh', value: 'I suspect an invalid domain name'})
    else
      path = {}
      hops = []
      hopr = PacketHopr.new(domain)

      hops = hopr.traceroute
      path = hopr.location(hops)

      JSON.pretty_generate(path)
    end
  end

  # start the server if ruby file executed directly
  run! if app_file == $0
end
