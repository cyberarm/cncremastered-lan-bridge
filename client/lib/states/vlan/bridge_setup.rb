module CncRemasteredLanBridge
  class States
    class VLAN
      class BridgeSetup < CyberarmEngine::GuiState
        def setup
          theme(THEME)

          background 0xff_252525

          stack(width: 1.0, height: 1.0, padding: 4) do
            banner "Virtual LAN", width: 1.0, text_align: :center
            tagline "Captures packets sent to certain local ports and forwards them over the VPN.", width: 1.0, text_align: :center

            stack(width: 1.0, max_width: 800, height: 1.0, max_height: 256, h_align: :center, padding: 10, border_thickness: 1, border_color: 0xff_ffffff) do
              background 0xff_111111

              flow(width: 1.0, height: 96) do
                stack(width: 0.5, height: 1.0, margin: 5, padding: 5, border_thickness: 1, border_color: 0x88_ffffff) do
                  tagline "LAN Interface", width: 1.0, text_align: :center, margin_top: 6, tip: "Interface of your real network/network with router"

                  flow(width: 1.0, fill: true) do
                    @lan_interface = list_box items: [""], fill: true, tip: "Select LAN interface"
                    button get_image("#{ROOT_PATH}/media/return.png"), min_width: 24, image_height: 1.0, tip: "Refresh interface list" do
                      refresh_ip_address_list
                    end
                  end
                end

                stack(width: 0.5, height: 1.0, margin: 5, padding: 5, border_thickness: 1, border_color: 0x88_ffffff) do
                  tagline "VPN Interface", width: 1.0, text_align: :center, margin_top: 6, tip: "Interface of the VPN network"

                  flow(width: 1.0, fill: true) do
                    @vpn_interface = list_box items: [""], fill: true, tip: "Select VPN interface"
                    button get_image("#{ROOT_PATH}/media/return.png"), min_width: 24, image_height: 1.0, tip: "Refresh interface list" do
                      refresh_ip_address_list
                    end
                  end
                end
              end

              flow(width: 1.0, fill: true) do
                stack(fill: true, height: 1.0) do
                  flow(fill: true)

                  button "Back" do
                    pop_state
                  end
                end

                stack(fill: true, height: 1.0) do
                  flow(fill: true)

                  para "Multicast Proxy not working?", width: 1.0, text_align: :center
                  para "Try directly connecting to peers.", width: 1.0, text_align: :center, margin_top: -4
                  inscription "(Lobby server connection required)", width: 1.0, text_align: :center, margin_top: -4

                  flow(width: 1.0, height: 36) do
                    flow(fill: true)

                    stack(min_width: 140, height: 1.0) do
                      # @join_btn = button "Join Room" do
                      #   if CncRemasteredLanBridge::Net::Client.instance&.connected?
                      #     push_state(JoinRoomDialog, mode: :vlan, real_lan_interface: @lan_interface.value, real_vpn_interface: @vpn_interface.value)
                      #   else
                      #     push_state(LobbyServerConnectionDialog, forward: JoinRoomDialog, real_lan_interface: @lan_interface.value, real_vpn_interface: @vpn_interface.value)
                      #   end
                      # end

                      # @create_btn = button "Create Room" do
                      #   if CncRemasteredLanBridge::Net::Client.instance&.connected?
                      #     push_state(CreateRoomDialog, mode: :vlan, real_lan_interface: @lan_interface.value, real_vpn_interface: @vpn_interface.value)
                      #   else
                      #     push_state(LobbyServerConnectionDialog, forward: CreateRoomDialog, real_lan_interface: @lan_interface.value, real_vpn_interface: @vpn_interface.value)
                      #   end
                      # end

                      @lobby_btn = button "Lobby" do
                        push_state(LobbyServerConnectionDialog, forward: Lobby, real_lan_interface: @lan_interface.value, real_vpn_interface: @vpn_interface.value)
                      end
                    end

                    flow(fill: true)
                  end
                end

                stack(fill: true, height: 1.0) do
                  flow(fill: true)

                  flow(width: 1.0, height: 36) do
                    flow(fill: true)

                    @start_btn = button "Start Multicast Proxy", min_width: 200, h_align: :right, enabled: false do
                      push_state(Dashboard, real_lan_interface: @lan_interface.value, real_vpn_interface: @vpn_interface.value)
                    end
                  end
                end
              end
            end
          end

          @lan_interface.subscribe(:changed) do
            @lobby_btn.enabled = interfaces_valid?
            @start_btn.enabled  = interfaces_valid?
          end

          @vpn_interface.subscribe(:changed) do
            @lobby_btn.enabled = interfaces_valid?
            @start_btn.enabled  = interfaces_valid?
          end

          refresh_ip_address_list(true)
        end

        def refresh_ip_address_list(initial = false)
          @local_ip_addresses = Socket.ip_address_list.select(&:ipv4?).map(&:ip_address).select { |ip| ip != "127.0.0.1" }
          @local_ip_addresses = [""] if @local_ip_addresses.empty?

          @lan_interface.items = @local_ip_addresses.clone
          @vpn_interface.items = @local_ip_addresses.clone

          return unless initial

          return unless @local_ip_addresses.size > 1

          # Assume 192.168.0 and 192.168.1 are LAN interfaces
          @lan_interface.value = @local_ip_addresses.find { |ip| ip.start_with?("192.168.0.") || ip.start_with?("192.168.1.") }
          @vpn_interface.value = @local_ip_addresses.find { |ip| !ip.start_with?("192.168.0.") && !ip.start_with?("192.168.1.") }
        end

        def interfaces_valid?
          @lan_interface.value != @vpn_interface.value &&
            @local_ip_addresses.include?(@lan_interface.value) &&
            @local_ip_addresses.include?(@vpn_interface.value)
        end
      end
    end
  end
end
