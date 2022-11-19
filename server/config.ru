require File.expand_path("server", __dir__)

map "/api/v1/websocket" do
  run CncRemasteredLanBridge::WebSocketRouter
end
