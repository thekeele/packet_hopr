require 'sinatra/base'

module Sinatra
  module PacketHoprAPI
    module Routing
      module Routes
        def self.registered(app)
          app.before do
            content_type :json

            if request.path_info.count('/') > 1
              redirect '/error'
            end
          end

          app.get '/' do
            JSON.pretty_generate({key: 'Welcome to PacketHopr', value: 'add /DOMAIN_NAME to see your path'})
          end

          app.get '/:domain' do
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
        end
      end
    end
  end
end
