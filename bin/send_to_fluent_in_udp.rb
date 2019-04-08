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

d = %x( env LANG=us_US.UTF-8 date "+%b %d %H:%M:%S" )
h = %x( hostname )
pid = Process.pid

msg = "<150>#{d} #{h} syslog-netcat-test[#{pid}]: testing baby"

# This example uses json payload.
# In in_udp configuration, need to configure "@type json" in "<parse>"
us.send(msg, 0, sa)
# us.send('{"k":"v2"}', 0, sa)
us.close
