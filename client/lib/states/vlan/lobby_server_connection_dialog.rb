module CncRemasteredLanBridge
  class States
    class VLAN
      class LobbyServerConnectionDialog < CyberarmEngine::GuiState
        def self.instance=(i)
          @instance = i
        end

        def self.instance
          @instance
        end

        def setup
          LobbyServerConnectionDialog.instance = self

          @last_status = nil

          theme(THEME)

          background 0xdd_000000

          stack(width: 320, height: 320, padding: 10, v_align: :center, h_align: :center, border_color: 0xaa_ffffff, border_thickness: 1) do
            background 0xff_222222

            banner "Lobby Server", width: 1.0, text_align: :center
            flow(fill: true)
            @status_label = tagline "Establishing connection...", width: 1.0, color: 0xaa_ffffff, text_align: :center
            flow(fill: true)

            flow(width: 1.0, height: 36) do
              @btn = button "Cancel" do
                pop_state
              end
            end
          end

          @created_time = Gosu.milliseconds
        end

        def draw
          previous_state&.draw

          Gosu.flush

          super
        end

        def update
          super

          if Gosu.milliseconds - @created_time >= 250 && !@connecting
            @connecting = true

            window.connect_ws_client!
          end

          if Gosu.milliseconds - @created_time >= 1_000 && CncRemasteredLanBridge::Net::Client.instance&.connected?
            pop_state
            push_state(@options[:forward], mode: :vlan, real_lan_interface: @options[:real_lan_interface], real_vpn_interface: @options[:real_vpn_interface])
          end

          if @connecting
            if CncRemasteredLanBridge::Net::Client.instance&.connected?
              if @last_status != :connected
                @status_label.style.color = 0xff_008800
                @status_label.style.default[:color] = 0xff_008800

                @status_label.value = "Connection established."

                @created_time = Gosu.milliseconds
              end

              @last_status = :connected
            elsif CncRemasteredLanBridge::Net::Client.instance&.closed?
              if @last_status != :error
                @status_label.style.color = 0xff_ff8800
                @status_label.style.default[:color] = 0xff_ff8800

                @status_label.value = "Failed to connect."

                @btn.value = "Close"
              end

              @last_status = :error
            end
          end
        end

        def handle_event(hash)
        end
      end
    end
  end
end
