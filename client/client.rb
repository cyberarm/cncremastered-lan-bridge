require "etc"
require "json"
require "socket"

require "cyberarm_engine"
require "websocket-client-simple"

require_relative "lib/theme"
require_relative "lib/window"
require_relative "lib/states/lobby"
require_relative "lib/states/room"
require_relative "lib/states/create_room_dialog"
require_relative "lib/states/join_room_dialog"

require_relative "lib/net/client"
require_relative "lib/net/stun"
require_relative "lib/net/peer"

CncRemasteredLanBridge::Window.new(width: 900, height: 600, resizable: true).show
