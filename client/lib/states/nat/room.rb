module CncRemasteredLanBridge
  class States
    class Room < CyberarmEngine::GuiState
      def self.instance=(i)
        @instance = i
      end

      def self.instance
        @instance
      end

      def setup
        Room.instance = self

        @room_data = @options[:room]
        @room_owner = @room_data[:owner_name] == @room_data[:member_name]
        @peer_count = 0

        theme(THEME)

        stack(width: 1.0, height: 1.0, padding: 10) do
          background 0xff_222222

          banner @room_data[:room_name], width: 1.0, text_align: :center

          @peers_label = title "Peers (0)"
          @peer_container = stack(width: 1.0, fill: true, scroll: true) do
          end

          button "#{@room_owner ? 'Destroy' : 'Leave'} Room", width: 1.0, max_width: 128, margin_top: 20 do |btn|
            CncRemasteredLanBridge::Net::Client.instance.write(
              {
                type: :leave_room,
                room_name: @room_data[:room_name],
                member_id: @room_data[:member_id]
              }.to_json
            )

            btn.enabled = false
          end
        end
      end

      def handle_event(hash)
        pp hash

        case hash[:type].to_sym
        when :leave_room
          pop_state
        when :destroy_room
          pop_state if @room_owner

          unless @room_owner
            pop_state
            # TODO: Show dialog saying the room owner has left and as such the room is dead
            #       and that connected peers will remain connected until their comm service
            #       dies or is otherwise disconnected.
          end
        when :add_member
          add_member(hash)
        when :remove_member
        end
      end

      def add_member(hash)
        pp hash

        @peer_count += 1

        @peers_label.value = "Peers (#{@peer_count})"

        @peer_container.append do
          flow(width: 1.0, height: 32, padding: 4) do
            background 0x88_448800 if hash[:member_name] == @room_data[:member_name]
            background 0x88_ff8800 if hash[:room_owner] # Room Owner

            flow(width: 0.25, height: 1.0) do
              image get_image("#{ROOT_PATH}/media/sprite_0086.png"), height: 1.0, tip: "Room Owner" if hash[:room_owner]

              tagline hash[:member_name]
            end

            caption "Comm", tip: "Communication service"
            image get_image("#{ROOT_PATH}/media/emote_circle.png"), height: 1.0, tip: "Connected to peer."

            caption "Lobby", margin_left: 50, tip: "Game lobby service"
            image get_image("#{ROOT_PATH}/media/emote_dots3.png"), height: 1.0, tip: "Connecting to peer..."

            caption "Match", margin_left: 50, tip: "Game match service (Only expected to connect after the host starts the game)"
            image get_image("#{ROOT_PATH}/media/emote_exclamation.png"), height: 1.0, tip: "Failed to connect to peer!"
            image get_image("#{ROOT_PATH}/media/emote_sleeps.png"), height: 1.0, tip: "Not connected to peer, yet."
          end
        end
      end

      def remove_member(hash)
        pp hash

        @peer_count -= 1
      end
    end
  end
end
