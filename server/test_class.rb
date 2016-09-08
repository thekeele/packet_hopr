require_relative 'packet_hopr'

path = {}
hops = []
hopr = PacketHopr.new('dev.keele.me')

hops = hopr.traceroute
path = hopr.location(hops)

puts hopr.inspect
puts hops.inspect
puts path
