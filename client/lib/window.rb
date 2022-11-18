module CncRemasteredLanBridge
  def self.input_nickname_filter(t)
    t =~ /\w/ ? t : ""
  end

  def self.input_room_name_filter(t)
    t =~ /[\w' -]/ ? t : ""
  end

  class Window < CyberarmEngine::Window
    def setup
      self.show_cursor = true
      self.caption = "Command & Conquer: Remastered LAN Bridge"

      push_state(States::Lobby)
    end
  end
end
