module ENet
  class Server
    def initialize(host:, port:, max_clients: 16, channels: 8, download_bandwidth: 0, upload_bandwidth: 0)
      @host = host
      @port = port
      @max_clients = max_clients
      @channels = channels
      @download_bandwidth = download_bandwidth
      @upload_bandwidth = upload_bandwidth

      @enet_event = LibENet::ENetEvent.new
      @clients = {}

      ENet.init

      @_address = LibENet::ENetAddress.new
      if LibENet.enet_address_set_host(@_address, @host) != 0
        raise "Failed to set host"
      end
      @_address[:port] = @port

      @_host = LibENet.enet_host_create(@_address, @max_clients, @channels, @download_bandwidth, @upload_bandwidth)
      pp @_host
      if @_host == nil
        raise "Failed to create server"
      end
    end

    def disconnect_client(client)
    end

    def send_packet(client, data, reliable:, channel:)
      packet = LibENet.enet_packet_create(data, data.length, reliable ? 1 : 0)
      LibENet.enet_peer_send(client._peer, channel, packet)

      pp [
        client.packets_sent,
        client.packets_received,
        client.data_sent,
        client.data_received,

        client.packets_lost,
        client.packet_loss,

        client.round_trip_time,
        client.last_round_trip_time,

        client.last_receive_time,
        client.last_send_time
      ]
    end

    def broadcast_packet(data, reliable:, channel:)
      packet = LibENet.enet_packet_create(data, data.length, reliable ? 1 : 0)
      LibENet.enet_host_broadcast(@_host, channel, packet)
    end

    def send_queued_packets
    end

    def update(timeout_ms)
      result = LibENet.enet_host_service(@_host, @enet_event, timeout_ms)

      if result.positive?
        case @enet_event[:type]
        when :ENET_EVENT_TYPE_NONE
          puts :ENET_EVENT_TYPE_NONE

        when :ENET_EVENT_TYPE_CONNECT
          client = Client.new(@enet_event[:peer])
          @clients[client] = @enet_event[:peer]

          on_connection(client)

        when :ENET_EVENT_TYPE_RECEIVE
          client = @clients.find { |k, peer| peer.to_ptr == @enet_event[:peer].to_ptr }.first
          data = @enet_event[:packet][:data].read_string(@enet_event[:packet][:length])

          on_packet_received(client, data, @enet_event[:channel_id])

          LibENet.enet_packet_destroy(@enet_event[:packet])

        when :ENET_EVENT_TYPE_DISCONNECT
          puts :ENET_EVENT_TYPE_DISCONNECT
        end
      elsif result.negative?
        warn "An error occurred"
      end
    end

    def use_compression(bool)
    end

    def on_connection(client)
    end

    def on_packet_received(client, data, channel)
    end

    def on_disconnection(client)
    end
  end
end
