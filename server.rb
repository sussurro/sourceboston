require 'socket'
require 'base64'
port = 1234
s = UDPSocket.new
s.bind('0.0.0.0', port)
while true
  text, sender = s.recvfrom(128)
  remote_host = sender[3]
  cmd = Base64.decode64(text)
  puts "#{remote_host} sent #{cmd}"
end

