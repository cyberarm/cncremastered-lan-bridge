require "ffi"

module LibENet
  extend FFI::Library
  ffi_lib "#{File.expand_path(__dir__)}/enet.dll"

  def self._windows?
    RUBY_PLATFORM =~ /mswin$|mingw|win32\-|\-win32/
  end

  # Enums
  ENetEventType = enum(
    :ENET_EVENT_TYPE_NONE,
    :ENET_EVENT_TYPE_CONNECT,
    :ENET_EVENT_TYPE_DISCONNECT,
    :ENET_EVENT_TYPE_RECEIVE
  )

  ENetSocketOption = enum(
    :ENET_SOCKOPT_NONBLOCK,
    :ENET_SOCKOPT_BROADCAST,
    :ENET_SOCKOPT_RCVBUF,
    :ENET_SOCKOPT_SNDBUF,
    :ENET_SOCKOPT_REUSEADDR,
    :ENET_SOCKOPT_RCVTIMEO,
    :ENET_SOCKOPT_SNDTIMEO,
    :ENET_SOCKOPT_ERROR,
    :ENET_SOCKOPT_NODELAY
  )

  ENetSocketType = enum(
    :ENET_SOCKET_TYPE_STREAM,
    :ENET_SOCKET_TYPE_DATAGRAM
  )

  # Structs
  class ENetAddress < FFI::Struct
    layout :host, :uint,
           :port, :ushort
  end

  class ENetPacket < FFI::Struct
    layout :_ref_count, :size_t,
           :flags,      :uint,
           :data,       :pointer,
           :length,     :short,
           :callback,   :pointer,
           :user_data,  :pointer
  end

  # Why on earth would you do this? They're the same types...
  if _windows?
    # Windows O_o
    class ENetBuffer < FFI::Struct
      layout :length, :size_t,
            :data,   :pointer
    end
  else
    # Unix o_O
    class ENetBuffer < FFI::Struct
      layout :data,   :pointer,
            :length, :size_t
    end
  end

  class ENetCompressor < FFI::Struct
    layout :context,    :pointer,
           :compress,   :pointer, # FIXME: http://sauerbraten.org/enet/structENetCompressor.html
           :decompress, :pointer, # FIXME
           :destroy,    :pointer  # FIXME
  end

  # FIXME: Layout is wrong due to doxygen alphabetizing fields...
  class ENetHost < FFI::Struct
    layout :socket,                       :pointer, # FIXME
           :address,                      ENetAddress,
           :bandwidth_limited_peers,      :size_t,
           :bandwidth_throttle_epoch,     :uint,
           :buffer_count,                 :size_t,
           :buffers,                      :pointer, # FIXME: http://sauerbraten.org/enet/structENetHost.html
           :channel_limit,                :size_t,
           :checksum,                     :pointer, # FIXME
           :command_count,                :size_t,
           :commands,                     :pointer, # FIXME
           :compress,                     :pointer, # FIXME
           :connected_peers,              :size_t,
           :continue_sending,             :int,
           :dispatch_queue,               :pointer, # FIXME
           :duplicate_peers,              :size_t,
           :header_flags,                 :ushort,
           :incoming_bandwidth,           :uint,
           :intercept,                    :pointer, # FIXME
           :maximum_packet_size,          :size_t,
           :maximum_waiting_data,         :size_t,
           :mtu,                          :uint,
           :outgoing_bandwidth,           :uint,
           :packet_data,                  :pointer, # FIXME
           :packet_size,                  :size_t,
           :peer_count,                   :size_t,
           :random_seed,                  :uint,
           :recalculate_bandwidth_limits, :int,
           :received_address,             ENetAddress,
           :received_data,                :ushort,
           :received_data_length,         :size_t,
           :service_time,                 :uint,
           :total_received_data,          :uint,
           :total_received_data,          :uint,
           :total_sent_packets,           :uint,
           :total_sent_packets,           :uint
  end

  # FIXME: Layout is wrong due to doxygen alphabetizing fields...
  class ENetPeer < FFI::Struct
    layout :acknowledgements,                  :pointer, # FIXME: http://sauerbraten.org/enet/structENetPeer.html
           :host,                              ENetHost.by_ref,
           :address,                           ENetAddress,
           :channel_count,                     :size_t,
           :channels,                          :pointer, # FIXME
           :connect_id,                        :uint,
           :data,                              :pointer,
           :dispatched_commands,               :pointer, # FIXME
           :dispatch_list,                     :pointer, # FIXME
           :earliest_timeout,                  :uint,
           :event_data,                        :uint,
           :flags,                             :ushort,
           :highest_round_trip_time_variance,  :uint,
           :incoming_bandwidth,                :uint,
           :incoming_bandwidth_throttle_epoch, :uint,
           :incoming_data_total,               :uint,
           :incoming_peer_id,                  :ushort,
           :incoming_session_id,               :uchar,
           :incoming_unsequenced_group,        :ushort,
           :last_receive_time,                 :uint,
           :last_round_trip_time,              :uint,
           :last_round_trip_variance,          :uint,
           :last_send_time,                    :uint,
           :lowest_round_time_time,            :uint,
           :mtu,                               :uint,
           :next_timeout,                      :uint,
           :outgoing_bandwidth,                :uint,
           :outgoing_commands,                 :pointer, # FIXME,
           :outgoing_data_total,               :uint,
           :outgoing_peer_id,                  :ushort,
           :outgoing_reliable_sequence_number, :ushort,
           :outgoing_session_id,               :uchar,
           :packet_loss,                       :uint,
           :packet_loss_epoch,                 :uint,
           :packet_loss_variance,              :uint,
           :packets_lost,                      :uint,
           :packet_throttle,                   :uint,
           :packet_throttle_acceleration,      :uint,
           :packet_throttle_counter,           :uint,
           :packet_throttle_deceleration,      :uint,
           :packet_throttle_epoch,             :uint,
           :packet_throttle_interval,          :uint,
           :packet_throttle_limit,             :uint,
           :ping_interval,                     :uint,
           :reliable_data_in_transit,          :uint,
           :_reserved,                         :ushort,
           :round_trip_time,                   :uint,
           :round_trip_time_variance,          :uint,
           :sent_reliable_commands,            :pointer, # FIXME
           :sent_unreliable_commands,          :pointer, # FIXME
           :state,                             :pointer, # FIXME,
           :timeout_limit,                     :uint,
           :timeout_maximum,                   :uint,
           :timeout_minimum,                   :uint,
           :total_waiting_data,                :size_t,
           :unsequenced_window,                :uint, # FIXME
           :window_size,                       :uint # FIXME: `unsequenced_window` appears to be an array of uint32, `window_size` offset WILL be wrong
  end

  class ENetEvent < FFI::Struct
    layout :type,       ENetEventType,
           :peer,       ENetPeer.by_ref,
           :channel_id, :uchar,
           :data,       :uint,
           :packet,     ENetPacket.by_ref
  end

  # Global
  attach_function :enet_deinitialize, [], :void
  attach_function :enet_initialize, [], :void
  attach_function :enet_initialize_with_callbacks, [:uint, :pointer], :void # FIXME
  attach_function :enet_linked_version, [], :int

  # Address
  attach_function :enet_address_get_host, [ENetAddress.by_ref, :string, :size_t], :int
  attach_function :enet_address_get_host_ip, [ENetAddress.by_ref, :string, :size_t], :int
  attach_function :enet_address_set_host, [ENetAddress.by_ref, :string], :int
  attach_function :enet_address_set_host_ip, [ENetAddress.by_ref, :string], :int

  # Host
  attach_function :enet_host_bandwidth_limit, [ENetHost.by_ref, :uint, :uint], :void
  attach_function :enet_host_broadcast, [ENetHost.by_ref, :uchar, :pointer], :void
  attach_function :enet_host_channel_limit, [ENetHost.by_ref, :size_t], :void
  attach_function :enet_host_check_events, [ENetHost.by_ref, ENetEvent.by_ref], :int
  attach_function :enet_host_compress, [ENetHost.by_ref, ENetCompressor.by_ref], :int
  attach_function :enet_host_compress_with_range_coder, [ENetHost.by_ref, ], :int
  attach_function :enet_host_connect, [ENetHost.by_ref, ENetAddress.by_ref, :size_t, :uint], ENetPeer.by_ref
  attach_function :enet_host_create, [ENetAddress.by_ref, :size_t, :size_t, :uint, :uint], ENetHost.by_ref
  attach_function :enet_host_destroy, [ENetHost.by_ref], :void
  attach_function :enet_host_flush, [ENetHost.by_ref], :void
  attach_function :enet_host_service, [ENetHost.by_ref, ENetEvent.by_ref, :uint], :int, blocking: true

  # Packet
  attach_function :enet_crc32, [:pointer, :size_t], :uint
  attach_function :enet_packet_create, [:string, :size_t, :uint], ENetPacket.by_ref
  attach_function :enet_packet_destroy, [ENetPacket.by_ref], :void
  attach_function :enet_packet_resize, [ENetHost.by_ref, :size_t], :int

  # Peer
  attach_function :enet_peer_disconnect, [ENetPeer.by_ref, :uint], :void
  attach_function :enet_peer_disconnect_later, [ENetPeer.by_ref, :uint], :void
  attach_function :enet_peer_disconnect_now, [ENetPeer.by_ref, :uint], :void
  attach_function :enet_peer_ping, [ENetPeer.by_ref], :void
  attach_function :enet_peer_ping_interval, [ENetPeer.by_ref, :uint], :void
  attach_function :enet_peer_receive, [ENetPeer.by_ref, :uchar], :pointer # FIXME
  attach_function :enet_peer_reset, [ENetPeer.by_ref], :void
  attach_function :enet_peer_send, [ENetPeer.by_ref, :ushort, ENetPacket.by_ref], :int
  attach_function :enet_peer_throttle_configure, [ENetPeer.by_ref, :uint, :uint, :uint], :void
  attach_function :enet_peer_timeout, [ENetPeer.by_ref, :uint, :uint, :uint], :void

  # Range Coder
  attach_function :enet_range_coder_compress, [:pointer, ENetBuffer.by_ref, :size_t, :size_t, :uchar, :size_t], :size_t
  attach_function :enet_range_coder_create, [], :pointer
  attach_function :enet_range_coder_decompress, [:pointer, :ushort, :size_t, :ushort, :size_t], :size_t
  attach_function :enet_range_coder_destroy, [:pointer], :void

  # Socket
  # typedef(:int, :ENetSocket)

  # attach_function :enet_socket_accept, [:ENetSocket, ENetAddress.by_ref], :ENetSocket
  # attach_function :enet_socket_bind, [:ENetSocket, ENetAddress.by_ref], :int
  # attach_function :enet_socket_connect, [:ENetSocket, ENetAddress.by_ref], :int
  # attach_function :enet_socket_create, [:uint], :ENetSocket
  # attach_function :enet_socket_destroy, [:ENetSocket], :void
  # attach_function :enet_socket_get_address, [:ENetSocket, ENetAddress.by_ref], :int
  # attach_function :enet_socket_get_option, [:ENetSocket, ENetSocketOption, :int], :int
  # attach_function :enet_socket_listen, [:ENetSocket, :int], :int
  # attach_function :enet_socket_receive, [:ENetSocket, ENetAddress.by_ref, ENetBuffer.by_ref, :size_t], :int
  # attach_function :enet_socket_send, [:ENetSocket, ENetAddress.by_ref, ENetBuffer.by_ref, :size_t], :int
  # attach_function :enet_socket_set_option, [:ENetSocket, ENetSocketOption, :pointer], :int
  # attach_function :enet_socket_shutdown, [:ENetSocket, ENetSocketShutdown], :int
  # attach_function :enet_socket_wait, [:ENetSocket, :pointer, :uint], :int
  # attach_function :enet_socketset_select, [:ENetSocket, ENetSocketSet.by_ref, ENetSocketSet.by_ref, :uint], :int

  # Time
  attach_function :enet_time_get, [], :uint
  attach_function :enet_time_set, [:uint], :void
end

# pp LibENet.enet_linked_version
# LibENet.enet_initialize

# addr = LibENet::ENetAddress.new
# LibENet.enet_address_set_host(addr, "localhost")
# addr[:port] = 3000
# pp addr
# pp addr[:host]
# pp addr[:port]

# host = LibENet.enet_host_create(addr, 8, 8, 0, 0)
# pp host
# pp host[:total_sent_packets]
# pp LibENet.enet_host_service(host, nil, 0)
# pp LibENet.enet_host_flush(host)
# pp LibENet.enet_host_destroy(host)

# pp LibENet.enet_time_get


# LibENet.enet_deinitialize


require_relative "renet/renet"
require_relative "renet/server"
require_relative "renet/connection"
require_relative "renet/client"

Thread.new do
  server = ENet::Server.new(host: "localhost", port: 3000, max_clients: 32, channels: 4, download_bandwidth: 0, upload_bandwidth: 0)
  def server.on_connection(client)
    puts "[ID #{client.id}] connected from #{client.address.host}"
    send_packet(client, "Hello World", reliable: true, channel: 1)
  end

  def server.on_packet_received(client, data, channel)
    puts "[ID #{client.id}] connected from #{client.address.host}"
    send_packet(client, "Hello World", reliable: true, channel: 1)
  end

  def server.on_disconnection(client)
    puts "[ID #{client.id}] disconnected from #{client.address.host}"
    send_packet(client, "Goodbye World", reliable: true, channel: 1)
  end

  while true
    server.update(1_000)
  end
end

sleep 0.5

connection = ENet::Connection.new(host: "localhost", port: 3000, channels: 4, download_bandwidth: 0, upload_bandwidth: 0)
def connection.on_connection
  puts "CONNECTED TO SERVER"
  send_packet("Hello World!", reliable: true, channel: 0)
end

def connection.on_packet_received(data, channel)
  puts "[CHANNEL #{channel}]: #{data}"

  send_packet(data, reliable: true, channel: channel)
end

def connection.on_disconnection
  puts "DISCONNECTED FROM SERVER"
end

connection.connect(5_000)

while true
  connection.update(1_000)
end
