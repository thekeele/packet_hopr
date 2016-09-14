require 'sinatra/base'

# nested modules based on register in api.rb
module Sinatra
  module PacketHoprAPI
    module Routing
      module Routes
        # define a function that's registered as the app from api.rb
        def self.registered(app)
          # before any request is processed, run this block
          app.before do
            # all requests serve json
            content_type :json

            # this app does not allow nested slashes
            if request.path_info.count('/') > 1
              # more than one slash results in error
              redirect '/error'
            end
          end

          # default route, will be removed as some point
          app.get '/' do
            JSON.pretty_generate({key: 'Welcome to PacketHopr', value: 'add /DOMAIN_NAME to see your path'})
          end

          # dynamic route, expected a valid domain name
          app.get '/:domain' do
            # pull the domain name from parameters
            domain = params[:domain]
            # what constitutes a valid domain name
            regex = /^[a-zA-Z0-9][a-zA-Z0-9\-_]{0,61}[a-zA-Z0-9]{0,1}\.([a-zA-Z]{1,6}|[a-zA-Z0-9\-]{1,30}\.[a-zA-Z]{2,3})$/

            # match will return nil if a match is not found
            if regex.match(domain).nil?
              # not an error, bad user input
              JSON.pretty_generate({key: 'Uh Oh', value: 'I suspect an invalid domain name'})
            else
              # set up vars needed to process a domain name
              path = {}
              hops = []
              # instantiate a PacketHopr object initialized with the supplied domain
              hopr = PacketHopr.new(domain)

              # traceroute returns an array of ip addresses
              hops = hopr.traceroute
              # hops are supplied to location, returns a hash of hop location data
              path = hopr.location(hops)

              # render the path of the domain name
              JSON.pretty_generate(path)
            end
          end
        end
      end
    end
  end
end
