require 'socket'
require 'base64'

host = ARGV.shift
port = 1234
s = UDPSocket.new

loop do
File.open("commands.txt").each do |cmd|
  puts "Sending #{cmd}"
   s.send(Base64.strict_encode64(cmd.strip),0,host,port)
   #sleep(rand(5))
   sleep(1)
end
end
