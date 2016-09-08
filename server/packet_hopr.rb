require 'json'
require 'open-uri'

# if domain supplied use it otherwise use a default
ARGV.length == 1 ? domain = ARGV[0] : domain = 'www.google.com'
puts "Let's hop our way to #{domain}"

# URL which is used to get location data for each hop
base_url = 'http://ipinfo.io/'

# run traceroute on the user supplied domain
route = `traceroute #{domain}`

# parse the output and put each hop in an array
route_lines = route.split(/\n/)
hops = []

# loop through each line from traceroute on line and index
route_lines.each_with_index do |line, index|
  # use regex to scan each line for an IPv4 address
  ip = line.scan(/\d{1,3}[.]\d{1,3}[.]\d{1,3}[.]\d{1,3}/)

  # first line of traceroute tells us where we're starting
  if index.zero?
    puts "Hops to #{domain} (#{ip.join(',')})"
  else
    # sometimes traceroute can't resolve to an IP, security?
    if !ip.empty?
      puts "Hop #{index} -> #{ip}"

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

# loop through array of hops and make request on each IP
hops.each_with_index do |ip, index|
  build_str = ""

  if index == 2
    response = JSON.parse(open(base_url + ip).read)
    puts response
  end

  # if !response['city'].nil?
  #   build_str.concat(response['city'] + ', ')
  # end
  # if !response['region'].nil?
  #   build_str.concat(response['region'] + ', ')
  # end
  # if !response['country'].nil?
  #   build_str.concat(response['country'])
  # end

  # puts build_str
end
