module CncRemasteredLanBridge
  class States
    class CreateRoomDialog < CyberarmEngine::GuiState
      def self.instance=(i)
        @instance = i
      end

      def self.instance
        @instance
      end

      def setup
        CreateRoomDialog.instance = self

        theme(THEME)

        background 0xdd_000000

        stack(width: 320, height: 320, padding: 10, v_align: :center, h_align: :center, border_color: 0xaa_ffffff, border_thickness: 1) do
          background 0xff_222222

          banner "Create Room", width: 1.0, text_align: :center
          tagline "Nickname"
          @nickname = edit_line "#{Etc.getlogin}", width: 1.0, filter: CncRemasteredLanBridge.method(:input_nickname_filter)

          tagline "Room Name"
          @room_name = edit_line "#{Etc.getlogin}'s Game", width: 1.0, filter: CncRemasteredLanBridge.method(:input_room_name_filter)

          tagline "Password (Optional)"
          @password = edit_line "", width: 1.0, type: :password

          flow(fill: true)

          flow(width: 1.0) do
            button "Cancel" do
              pop_state
            end

            flow(fill: true)

            button "Create Room" do |btn|
              btn.enabled = false

              CncRemasteredLanBridge::Net::Client.instance.write(
                {
                  type: :create_room,
                  room_name: @room_name.value,
                  owner_name: @nickname.value,
                  password: @password.value
                }.to_json
              )
            end
          end
        end
      end

      def draw
        previous_state&.draw

        Gosu.flush

        super
      end

      def handle_event(hash)
        case hash[:type].to_sym
        when :create_room
          pp hash

          if hash[:error]
          else
            pop_state
            push_state(States::Room, room: hash)
          end
        end
      end
    end
  end
end
