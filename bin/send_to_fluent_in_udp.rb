#!/usr/bin/env ruby

# SOURCE: https://docs.fluentd.org/v1.0/articles/in_udp

require 'socket'

if ARGV.length < 1
  puts "Too few arguments"
  exit
end

# SOURCE: https://dzone.com/articles/send-custom-udp-packets-ruby
UDP_RECV_TIMEOUT = 3  # seconds

def q2cmd(server_addr, server_port, cmd_str)
  resp, sock = nil, nil
  begin
   cmd = "\377\377\377\377#{cmd_str}\0"
    sock = UDPSocket.open
    sock.send(cmd, 0, server_addr, server_port)
    resp = if select([sock], nil, nil, UDP_RECV_TIMEOUT)
      sock.recvfrom(65536)
    end
    if resp
      resp[0] = resp[0][4..-1]  # trim leading 0xffffffff
    end
  rescue IOError, SystemCallError
  ensure
    sock.close if sock
  end
  resp ? resp[0] : nil
end



puts "Host: #{ARGV[0]}"

us = UDPSocket.open
sa = Socket.pack_sockaddr_in(5140, ARGV[0])

d = %x( env LANG=us_US.UTF-8 date "+%b %d %H:%M:%S" ).strip
h = %x( hostname ).strip
pid = Process.pid

msg = "<150>#{d} #{h} syslog-netcat-test[#{pid}]: testing baby".strip

puts " [msg]: #{msg}".strip

# This example uses json payload.
# In in_udp configuration, need to configure "@type json" in "<parse>"
us.send("#{msg}", 0, sa)
# us.send('{"k":"v2"}', 0, sa)
us.close


# your firewall has to allow communication with IP address 67.19.248.74 (port 27912)
#server, port, cmd = *ARGV
# server = "#{ARGV[0]}"
# port = 5140
# cmd = "#{msg}"

# result = q2cmd(server, port, cmd)
# puts result
