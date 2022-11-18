require "etc"

require "cyberarm_engine"

require_relative "lib/theme"
require_relative "lib/window"
require_relative "lib/states/lobby"
require_relative "lib/states/room"
require_relative "lib/states/create_room_dialog"
require_relative "lib/states/join_room_dialog"

CncRemasteredLanBridge::Window.new(width: 900, height: 600, resizable: true).show
