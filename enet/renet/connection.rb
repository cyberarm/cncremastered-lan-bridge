module ENet
  class Connection
    def initialize(host:, port:, channels: 8, download_bandwidth: 0, upload_bandwidth: 0)
      @host = host
      @port = port
      @channels = channels
      @download_bandwidth = download_bandwidth
      @upload_bandwidth = upload_bandwidth

      @online = false

      ENet.init

      @_address = LibENet::ENetAddress.new
      if LibENet.enet_address_set_host(@_address, "localhost") != 0
        raise "Failed to set host"
      end
      @_address[:port] = @port

      @_host = LibENet.enet_host_create(nil, 1, @channels, @download_bandwidth, @upload_bandwidth)
      pp @_host
      if @_host == nil
        raise "Failed to create host"
      end
    end

    def connect(timeout_ms)
      @_connection = LibENet.enet_host_connect(@_host, @_address, @channels, 0)
      pp @_connection
      if @_connection == nil
        raise "Cannot connect to remote host"
      end

      enet_event = LibENet::ENetEvent.new
      result = LibENet.enet_host_service(@_host, enet_event, timeout_ms)

      if result.positive? && enet_event[:type] == :ENET_EVENT_TYPE_CONNECT
        @online = true

        on_connection
      end
    end

    def disconnect(timeout_ms)
    end

    def send_packet(data, reliable:, channel:)
      packet = LibENet.enet_packet_create(data, data.length, reliable ? 1 : 0)
      LibENet.enet_peer_send(@_connection, channel, packet)
    end

    def send_queued_packets
      LibENet.enet_host_flush(@_host)
    end

    def update(timeout_ms)
      enet_event = LibENet::ENetEvent.new
      result = LibENet.enet_host_service(@_host, enet_event, timeout_ms)

      if result.positive?
        pp [
            :connection,
            enet_event[:channel_id],
            enet_event[:data],
            enet_event[:packet],
            enet_event[:peer],
            enet_event[:type]
        ]

        case enet_event[:type]
        when :ENET_EVENT_TYPE_NONE
          puts :ENET_EVENT_TYPE_NONE

        when :ENET_EVENT_TYPE_CONNECT
          puts :ENET_EVENT_TYPE_CONNECT

        when :ENET_EVENT_TYPE_RECEIVE
          data = enet_event[:packet][:data].read_string(enet_event[:packet][:length])

          on_packet_received(data, enet_event[:channel_id])

        when :ENET_EVENT_TYPE_DISCONNECT
          puts :ENET_EVENT_TYPE_DISCONNECT
        end
      elsif result.negative?
        warn "An error occurred"
      end
    end

    def use_compression(bool)
    end

    def on_connection
    end

    def on_packet_received(data, channel)
    end

    def on_disconnection
    end
  end
end
