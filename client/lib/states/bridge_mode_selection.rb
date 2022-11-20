module CncRemasteredLanBridge
  class States
    class BridgeModeSelection < CyberarmEngine::GuiState
      def self.instance=(i)
        @instance = i
      end

      def self.instance
        @instance
      end

      def setup
        BridgeModeSelection.instance = self

        theme(THEME)

        background 0xff_252525

        banner "Command & Conquer: Remastered LAN Bridge", width: 1.0, text_align: :center

        stack(width: 1.0, max_width: 800, height: 1.0, max_height: 512, h_align: :center, padding: 10, border_thickness: 1, border_color: 0xff_ffffff) do
          background 0xff_111111

          title "Select Bridge Mode", width: 1.0, text_align: :center
          flow(width: 1.0, fill: true) do
            stack(width: 0.5, height: 1.0, margin: 5, padding: 5, border_thickness: 1, border_color: 0x88_ffffff, scroll: true) do
              button "Virtual LAN", width: 1.0 do
                push_state(VLAN::BridgeSetup)
              end
              tagline "<c=f08000>Easyish</c>: <c=00a000>Most Reliable</c>", text_align: :center, width: 1.0
              caption "    Client will bridge LAN multicast packets to a VPN interface."
              caption "    Requires an active VPN connection with all peers and for your local network to be 'private' so that multicast packets will not be dropped by your computer."

              flow(fill: true, min_height: 20)

              caption "Suggested VPN Software:", margin_top: 20, width: 1.0, text_align: :center

              flow(width: 1.0, height: 40) do
                flow(fill: true)

                button "ZeroTier", tip: "https://zerotier.com/" do
                  open_url("https://zerotier.com/")
                end

                flow(fill: true)
              end
            end

            stack(width: 0.5, height: 1.0, margin: 5, padding: 5, border_thickness: 1, border_color: 0x88_ffffff, scroll: true) do
              button "NAT Punch Through", width: 1.0, enabled: false do
                push_state(Lobby)
              end

              tagline "<c=00a000>Easy</c>: <c=f08000>Might Be Unreliable</c>", text_align: :center, width: 1.0
              caption "    Client will attempt to connect to peers via NAT-punch-through without needing a VPN connection."
              caption "    Requires your local network to be 'private' so that multicast packets will not be dropped by your computer."
              caption "    If your local router's NAT changes external ports from interal ports this will NOT work due to being unable to alter the port the game server sends to clients."
            end
          end

          stack(width: 1.0, height: 72, margin: 5, padding: 5, border_thickness: 1, border_color: 0x88_800000, scroll: true) do
            para "Alternatively, you can try to use the popular Radmin VPN to perhaps not need this bridge at all.", width: 1.0, text_align: :center

            flow(width: 1.0, height: 40) do
              flow(fill: true)

              button "Radmin VPN", tip: "https://www.radmin-vpn.com/" do
                open_url("https://www.radmin-vpn.com/")
              end

              flow(fill: true)
            end
          end
        end
      end

      def open_url(url)
        return unless url

        if Gem.win_platform?
          system("start #{url}")
        elsif RUBY_PLATFORM =~ /linux/
          system("xdg-open #{url}")
        else
          system("open #{url}")
        end
      end
    end
  end
end
