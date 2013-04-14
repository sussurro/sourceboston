#!/usr/bin/env ruby

require 'net/smtp'

host = ARGV.shift

msgstr = "From: Mike <falter@fake.email>
To: Ryan sussurro@fake.email>
Subject: Top secret stuff.

yo dude. Here's my secret biz.
"

Net::SMTP.start(host, 25) do |smtp|
  smtp.send_message msgstr,
                    'falter@fake.email',
                    'sussurro@fake.email'
end
