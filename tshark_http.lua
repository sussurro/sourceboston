-- Tshark filter for printing out HTTP request/response
-- Roughly based on https://www.ibm.com/developerworks/mydeveloperworks/blogs/kevgrig/entry/wireshark_automation_with_lua_scripting?lang=en

do
   print("Trace HTTP script loaded")
   local streams = {}

   -- IP SRC and DST
   local ip_dst = Field.new("ip.dst")
   local ip_src = Field.new("ip.src")

   -- TCP Destination and Source Port and Stream
   local tcp_dstport = Field.new("tcp.dstport")
   local tcp_srcport = Field.new("tcp.srcport")
   local tcp_stream = Field.new("tcp.stream")


   -- HTTP Method, URI, Host Header, Response Code, and Response Phrase
   local http_method = Field.new("http.request.method")
   local http_uri = Field.new("http.request.uri")
   local http_host = Field.new("http.host")
   local http_response_code = Field.new("http.response.code")
   local http_response_phrase = Field.new("http.response.phrase")


   local function init_listener()

      local tap = Listener.new("http")

      function tap.packet(pinfo,tvb)

         -- Get the IP info
         local ipdst = tostring(ip_dst())
         local ipsrc = tostring(ip_src())

         -- Get the TCP Information
         local dstport = tostring(tcp_dstport())
         local srcport = tostring(tcp_srcport())
         local stream = tostring(tcp_stream())
      

         -- If the response code is not nil, get the last request in the stream and print it out along with response info
         if http_response_code() ~= nil then
            local phrase = tostring(http_response_phrase())
            local response_code = tostring(http_response_code())
            if streams[stream] then
               io.write(string.format("%s:%s -> %s:%s %s %s (%s)\n", ipdst, dstport,ipsrc , srcport,streams[stream] ,response_code,phrase))
               streams[stream] = nil
             end

         -- If the method is present, then this is a request.  Save the fully qualified request to the streams array for retreival on reply
         else 
            local method = tostring(http_method())
            local uri = tostring(http_uri())
            local host = tostring(http_host())
            streams[stream] = method .. " http://" .. host .. uri
         end
      end
   end
   init_listener()
end
