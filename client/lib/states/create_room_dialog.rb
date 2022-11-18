module CncRemasteredLanBridge
  class States
    class CreateRoomDialog < CyberarmEngine::GuiState
      def setup
        theme(THEME)

        background 0xdd_000000

        stack(width: 320, height: 320, padding: 10, v_align: :center, h_align: :center, border_color: 0xaa_ffffff, border_thickness: 1) do
          background 0xff_222222

          banner "Create Room", width: 1.0, text_align: :center
          tagline "Nickname"
          edit_line "#{Etc.getlogin}", width: 1.0, filter: CncRemasteredLanBridge.method(:input_nickname_filter)

          tagline "Room Name"
          edit_line "#{Etc.getlogin}'s Game", width: 1.0, filter: CncRemasteredLanBridge.method(:input_room_name_filter)

          tagline "Password (Optional)"
          edit_line "", width: 1.0, type: :password

          flow(fill: true)

          flow(width: 1.0) do
            button "Cancel" do
              pop_state
            end

            flow(fill: true)

            button "Create Room" do
              pop_state
              push_state(States::Room)
            end
          end
        end
      end

      def draw
        previous_state&.draw

        Gosu.flush

        super
      end
    end
  end
end
