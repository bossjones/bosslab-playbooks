#!/usr/bin/env ruby

# SOURCE: https://docs.fluentd.org/v1.0/articles/in_udp

require 'socket'

if ARGV.length < 1
  puts "Too few arguments"
  exit
end

puts "Host: #{ARGV[0]}"

us = UDPSocket.open
sa = Socket.pack_sockaddr_in(5140, ARGV[0])

# This example uses json payload.
# In in_udp configuration, need to configure "@type json" in "<parse>"
us.send('{"k":"v1"}', 0, sa)
us.send('{"k":"v2"}', 0, sa)
us.close
