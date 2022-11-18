module CncRemasteredLanBridge
  class States
    class Room < CyberarmEngine::GuiState
      def setup
        theme(THEME)

        stack(width: 1.0, height: 1.0, padding: 10) do
          background 0xff_222222

          banner "ROOM NAME GOES HERE", width: 1.0, text_align: :center

          title "Peers"
          stack(width: 1.0, fill: true, scroll: true) do
            %w{ user jeff rob einstein red menance user jeff rob einstein red menance }.each_with_index do |nickname, i|
              flow(width: 1.0, height: 32, padding: 4) do
                background i.even? ? 0x88_111111 : 0xff_111111
                tagline "#{i + 1}. #{nickname}", width: 0.25

                if rand < 0.75
                  tagline "PENDING: Punching NAT...", color: 0xff_ff8800
                else
                  tagline "CONNECTED: #{rand(999)}B/s Down, #{rand(999)}B/s Up.", color: 0xff_00f000
                end
              end
            end
          end

          button "Leave Room", width: 1.0, max_width: 128, margin_top: 20 do
            pop_state
          end
        end
      end
    end
  end
end
