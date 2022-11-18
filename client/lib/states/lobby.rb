module CncRemasteredLanBridge
  class States
    class Lobby < CyberarmEngine::GuiState
      def setup
        theme(THEME)

        stack(width: 1.0, height: 1.0, padding: 10) do
          background 0xff_222222

          banner "Lobby", width: 1.0, text_align: :center

          flow(width: 1.0, fill: true) do
            stack(width: 0.60, height: 1.0, padding: 10, padding_left: 0) do
              title "Available Rooms (10)", width: 1.0, text_align: :center
              edit_line "", width: 1.0, margin_bottom: 10

              stack(width: 1.0, fill: true, scroll: true) do
                10.times do |i|
                  button "#{rand < 0.25 ? '[#] ' : ''}Room Epic Twins! #{i}", width: 1.0, text_align: :left
                end
              end
            end

            stack(width: 0.40, height: 1.0, scroll: true, padding: 10) do
              background 0xff_000000

              tagline "ROOM NAME", width: 1.0, text_align: :center
              para "PLAYER NAME1"
              para "PLAYER NAME2"
              para "PLAYER NAME3"
              para "PLAYER NAME4"

              flow(fill: true)

              button "Join Room", width: 1.0 do
                push_state(States::JoinRoomDialog)
              end
            end
          end

          flow(width: 1.0, height: 48, margin_top: 40) do
            flow(fill: true)

            button "Create Room" do
              push_state(States::CreateRoomDialog)
            end

            flow(fill: true)
          end
        end
      end
    end
  end
end
