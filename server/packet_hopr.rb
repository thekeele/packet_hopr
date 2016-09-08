require 'json'
require 'open-uri'

class PacketHopr
  # load up our @instance variables
  def initialize(domain)
    # destination domain we will be hopping to
    @domain = domain

    # URL which is used to get location data for each hop
    @base_url = 'http://ipinfo.io/'
  end

  def traceroute
    # run traceroute on the user supplied domain
    route = `traceroute #{@domain}`

    # parse the output and put each hop in an array
    route_lines = route.split(/\n/)
    hops = []

    # loop through each line from traceroute on line and index
    route_lines.each_with_index do |line, index|
      # use regex to scan each line for an IPv4 address
      ip = line.scan(/\d{1,3}[.]\d{1,3}[.]\d{1,3}[.]\d{1,3}/)

      # first line of traceroute tells us where we're starting
      if index.zero?
        # puts "Hops to #{@domain} (#{ip.join(',')})"
      else
        # sometimes traceroute can't resolve to an IP, security?
        if !ip.empty?
          # puts "Hop #{index} -> #{ip}"

          # some hops have multiple IPs so we account for that
          if ip.count == 1
            hops.push(ip.join(','))
          elsif ip.count > 1
            # multiples return an array of IPs
            ip.each do |hop|
              hops.push(hop)
            end
          end
        end
      end
    end

    return hops
  end

  def location(hops)
    # create hash for JSON response to API
    path = Hash.new

    # loop through array of hops and make request on each IP
    hops.each_with_index do |ip, index|
      # open HTTP connect on IP and parse returned JSON
      response = JSON.parse(open(@base_url + ip).read)

      # construct array of hop indexes and responses
      path[index] = response
    end

    return path
  end

  # end PacketHopr
end
