module CncRemasteredLanBridge
  ROOT_PATH = File.expand_path("../..", __FILE__)

  def self.input_nickname_filter(t)
    t =~ /\w/ ? t : ""
  end

  def self.input_room_name_filter(t)
    t =~ /[\w' -]/ ? t : ""
  end

  class Window < CyberarmEngine::Window
    attr_reader :client

    def setup
      self.show_cursor = true
      self.caption = "Command & Conquer: Remastered LAN Bridge"

      @ui_queue = []

      # push_state(States::Lobby)
      push_state(States::BridgeModeSelection)
    end

    def connect_ws_client!
      return if @client && !@client.closed?

      Thread.new do
        @client = CncRemasteredLanBridge::Net::Client.new(handler: Handler.new)
        @client.connect!
      end
    end

    def update
      super

      while(block = @ui_queue.shift)
        block.call
      end

      # Enable CRuby's thread sheduler to switch to websocket thread
      sleep 0.004
    end

    def run_on_ui_thread(&block)
      @ui_queue << block
    end

    class Handler
      def event(hash)
        case hash[:type].to_sym
        when :listing
          CncRemasteredLanBridge::Window.instance.run_on_ui_thread do
            CncRemasteredLanBridge::States::Lobby.instance&.handle_event(hash)
          end
        when :create_room
          CncRemasteredLanBridge::Window.instance.run_on_ui_thread do
            CncRemasteredLanBridge::States::CreateRoomDialog.instance&.handle_event(hash)
          end
        when :join_room
          CncRemasteredLanBridge::Window.instance.run_on_ui_thread do
            CncRemasteredLanBridge::States::JoinRoomDialog.instance&.handle_event(hash)
          end
        when :leave_room, :destroy_room, :add_member, :remove_member
          CncRemasteredLanBridge::Window.instance.run_on_ui_thread do
            CncRemasteredLanBridge::States::Room.instance&.handle_event(hash)
          end
        end
      end
    end
  end
end
