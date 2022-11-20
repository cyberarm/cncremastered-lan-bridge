module CncRemasteredLanBridge
  class States
    class VLAN
      class Dashboard < CyberarmEngine::GuiState
        attr_reader :log_container

        def setup
          theme(THEME)

          background 0xff_252525

          stack(width: 1.0, height: 1.0, padding: 4) do
            banner "Virtual LAN : Broadcast Forwarder", width: 1.0, text_align: :center

            stack(width: 1.0, max_width: 800, height: 1.0, max_height: 512, h_align: :center, padding: 10, border_thickness: 1, border_color: 0xff_ffffff) do
              background 0xff_111111

              flow(width: 1.0, height: 32, margin_left: 8) do
                @total_rx = tagline "Received: #{format_size(1024)}", fill: true, text_align: :center
                @total_tx = tagline "Transmitted: #{format_size(10240)}", fill: true, text_align: :center
                @total_bc = tagline "Forwarded: 0", fill: true, text_align: :center
              end

              @log_container = stack(width: 1.0, fill: true, padding: 2, scroll: true, border_thickness: 1, border_color: 0x88_ffffff) do
                background 0xaa_222222
              end

              flow(width: 1.0, height: 48, margin_top: 10) do
                stack(width: 200) do
                  inscription "LAN: #{@options[:real_lan_interface]}"
                  inscription "VPN: #{@options[:real_vpn_interface]}", margin_top: -4
                end

                stack(fill: true) do
                  # inscription "WARNING: No broadcasts detected!", color: 0xff_ff8800
                  # inscription "Is your game running and in the LAN Mode lobby?", margin_top: -4
                end

                button "Shutdown", tip: "Stop forwarder and close" do
                  @proto_repeater&.stop!
                  pop_state
                end
              end
            end
          end

          # @proto_proxy = ProtoProxy.new(gui: self)
          @proto_repeater = CncRemasteredLanBridge::Net::ProtoRepeater.new(
            lan_interface: @options[:real_lan_interface],
            vpn_interface: @options[:real_vpn_interface],
            gui: self
          )
          @last_transfer_refreshed_at = 0
        end

        def update
          super

          if Gosu.milliseconds - @last_transfer_refreshed_at >= 100.0
            @last_transfer_refreshed_at = Gosu.milliseconds

            @total_rx.value = "Received: #{format_size(@proto_repeater.total_rx)}"
            @total_tx.value = "Transmitted: #{format_size(@proto_repeater.total_tx)}"
            @total_bc.value = "Forwarded: #{@proto_repeater.broadcasts_forwarded}"

            # Discard old messages
            while (@log_container.children.count > 25)
              @log_container.children.shift

              @log_container.root.gui_state.request_recalculate_for(@log_container)
            end
          end
        end

        def log(message)
          # _last_scroll_position_y = @log_container.scroll_position.y
          # @log_container.scroll_position.y = -@log_container.max_scroll_height
          # root.gui_state.request_recalculate_for(@log_container) if _last_scroll_position_y != -@log_container.max_scroll_height

          @log_container.append do
            inscription "<c=2a2>[ #{Time.now.strftime('%Y-%m-%d %H:%M:%S')} ]</c><c=44a>></c> <c=ee0>#{message}</c>", text_shadow_color: 0xff_ffffff, text_shadow_size: 0.25
          end
        end

        def format_size(bytes)
          case bytes
          when 0..1023 # Bytes
            "#{bytes} B"
          when 1024..1_048_575 # KiloBytes
            "#{format_size_number(bytes / 1024.0)} KB"
          when 1_048_576..1_073_741_999 # MegaBytes
            "#{format_size_number(bytes / 1_048_576.0)} MB"
          else # GigaBytes
            "#{format_size_number(bytes / 1_073_742_000.0)} GB"
          end
        end

        def format_size_number(i)
          format("%0.2f", i)
        end
      end
    end
  end
end
