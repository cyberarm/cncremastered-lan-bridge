module CncRemasteredLanBridge
  class States
    class JoinRoomDialog < CyberarmEngine::GuiState
      def setup
        theme(THEME)

        background 0xdd_000000

        stack(width: 320, height: 320, padding: 10, v_align: :center, h_align: :center, border_color: 0xaa_ffffff, border_thickness: 1) do
          background 0xff_222222

          banner "Join Room", width: 1.0, text_align: :center
          tagline "ROOM NAME GOES HERE MATES", width: 1.0, color: 0xaa_ffffff

          tagline "Nickname", margin_top: 10
          edit_line "#{Etc.getlogin}", width: 1.0, filter: CncRemasteredLanBridge.method(:input_nickname_filter)

          tagline "Password (Optional)"
          edit_line "", width: 1.0, type: :password

          flow(fill: true)

          flow(width: 1.0) do
            button "Cancel" do
              pop_state
            end

            flow(fill: true)

            button "Join Room" do
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