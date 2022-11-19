require "socket"

require_relative "../client/lib/net/stun"

stun_client = CncRemasteredLanBridge::Net::STUN.new(port: 24_928, stun_host: "localhost")

loop do
  stun_client.update
end
