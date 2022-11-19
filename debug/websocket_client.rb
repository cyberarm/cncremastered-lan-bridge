require "json"
require "websocket-client-simple"

require_relative "../client/lib/net/client"

client = CncRemasteredLanBridge::Net::Client.new(handler: nil)
client.connect!

sleep
