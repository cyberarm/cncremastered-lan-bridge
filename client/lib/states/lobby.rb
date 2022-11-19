module CncRemasteredLanBridge
  class States
    class Lobby < CyberarmEngine::GuiState
      def self.instance=(i)
        @instance = i
      end

      def self.instance
        @instance
      end

      def setup
        Lobby.instance = self

        theme(THEME)

        stack(width: 1.0, height: 1.0, padding: 10) do
          background 0xff_222222

          banner "Lobby", width: 1.0, text_align: :center

          flow(width: 1.0, fill: true) do
            stack(width: 1.0, height: 1.0, padding: 10, padding_left: 0, padding_right: 0) do
              @available_rooms_label = title "Available Rooms (0)", width: 1.0, text_align: :center

              flow(width: 1.0, height: 36, margin_bottom: 10) do
                edit_line "", fill: true, height: 1.0
                button "Search", min_width: 128

                flow(fill: true)

                button "Create Room", min_width: 128 do
                  push_state(States::CreateRoomDialog)
                end
              end

              @room_list_container = stack(width: 1.0, fill: true, scroll: true) do
              end
            end
          end
        end
      end

      def handle_event(hash)
        case hash[:type].to_sym
        when :listing
          pp hash

          @available_rooms_label.value = "Available Rooms (#{hash[:rooms].count})"

          @room_list_container.clear do
            hash[:rooms]&.sort_by { |r| r[:room_name].strip.downcase }&.each_with_index do |room, i|
              flow(width: 1.0, height: 36, padding: 10) do
                background i.even? ? 0x88_111111 : 0xff_111111

                image get_image("#{ROOT_PATH}/media/locked.png"), height: 1.0 if room[:room_password]
                tagline room[:room_name], fill: true, height: 1.0, text_v_align: :center

                button("Join Room", min_width: 128) do
                  push_state(States::JoinRoomDialog, room: room)
                end
              end
            end
          end
        end
      end

      def populate_room_info(room)
        @room_info_container.clear do
          tagline room[:room_name], width: 1.0, text_align: :center, background: 0xff_111111, padding: 10
          para "PLAYER NAME1"
          para "PLAYER NAME2"
          para "PLAYER NAME3"
          para "PLAYER NAME4"

          flow(fill: true)

          button "Join Room", width: 1.0 do
          end
        end
      end
    end
  end
end
