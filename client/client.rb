require "etc"
require "json"
require "socket"

begin
  require_relative "../../cyberarm_engine/lib/cyberarm_engine"
rescue LoadError
  require "cyberarm_engine"
end
require "websocket-client-simple"

require_relative "lib/theme"
require_relative "lib/window"
require_relative "lib/states/bridge_mode_selection"

require_relative "lib/states/vlan/bridge_setup"
require_relative "lib/states/vlan/dashboard"
require_relative "lib/states/vlan/lobby_server_connection_dialog"

require_relative "lib/states/nat/lobby"
require_relative "lib/states/nat/room"
require_relative "lib/states/nat/create_room_dialog"
require_relative "lib/states/nat/join_room_dialog"

require_relative "lib/net/proto_repeater"
require_relative "lib/net/client"
require_relative "lib/net/stun"
require_relative "lib/net/peer"

CncRemasteredLanBridge::Window.new(width: 900, height: 600, resizable: true).show
