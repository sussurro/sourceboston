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

   -- if Add
   if cmd == "A" then
      local passwd = record[3]
      ettercap.log("NEW_CRED %s:%s\n", username, passwd)

   -- if Modify
   elseif cmd == "M" then
      local passwd = record[3]
      ettercap.log("MOD_CRED %s:%s\n", username, passwd)

   -- if Delete
   elseif cmd == "D" then
      ettercap.log("DEL_CRED %s\n", username)

   else
      ettercap.log("Unknown command %s\n", rawcmd)
   end
end


