require "ffi"

module LibENet
  extend FFI::Library
  ffi_lib "enet"

  # Enums
  enum :ENetEventType, [
    :none,
    :connect,
    :disconnect,
    :receive
  ]

  # Structs
  class ENetAddress < FFI::Struct
    layout :host, :uint,
           :port, :ushort
  end

  class ENetPacket < FFI::Struct
    layout :data,       :uchar,
           :length,     :short,
           :flags,      :uint,
           :callback,   :pointer,
           :_ref_count, :short,
           :user_data,  :pointer
  end

  class ENetBuffer < FFI::Struct
    layout :data,   :pointer,
           :length, :size_t
  end

  class ENetCompressor < FFI::Struct
    layout :compress,   :pointer, # FIXME: http://sauerbraten.org/enet/structENetCompressor.html
           :context,    :pointer,
           :decompress, :pointer, # FIXME
           :destroy,    :pointer  # FIXME
  end

  class ENetHost < FFI::Struct
    layout :address,                      ENetAddress,
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
           :socket,                       :pointer, # FIXME
           :total_received_data,          :uint,
           :total_received_data,          :uint,
           :total_sent_packets,           :uint,
           :total_sent_packets,           :uint

  end

  class ENetPeer < FFI::Struct
    layout :acknowledgements,                  :pointer, # FIXME: http://sauerbraten.org/enet/structENetPeer.html
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
           :host,                              ENetHost,
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
    layout :channel_id, :uchar,
           :data,       :uint,
           :packet,     ENetPacket,
           :peer,       ENetPeer,
           :type,      :int # ENetEventType
  end

  # Global
  attach_function :enet_linked_version, [], :int
  attach_function :enet_initialize, [], :void
  attach_function :enet_deinitialize, [], :void

  # Address
  attach_function :enet_address_get_host, [ENetAddress.by_ref, :string, :size_t], :int
  attach_function :enet_address_get_host_ip, [ENetAddress.by_ref, :string, :size_t], :int
  attach_function :enet_address_set_host, [ENetAddress.by_ref, :string], :int
  attach_function :enet_address_set_host_ip, [ENetAddress.by_ref, :string], :int

  # Host
  attach_function :enet_host_create, [ENetAddress.by_ref, :size_t, :size_t, :uint, :uint], :pointer # ENetHost*
  attach_function :enet_host_connect, [ENetHost.by_ref, ENetAddress.by_ref, :size_t, :uint], :pointer # ENetPeer*
  attach_function :enet_host_service, [ENetHost.by_ref, ENetEvent.by_ref, :uint], :int
  attach_function :enet_host_flush, [ENetHost.by_ref], :void
  attach_function :enet_host_bandwidth_limit, [ENetHost.by_ref, :uint, :uint], :void
  attach_function :enet_host_bandwidth_throttle, [ENetHost.by_ref], :void
  attach_function :enet_host_broadcast, [ENetHost.by_ref, :uchar, :pointer], :void
  attach_function :enet_host_channel_limit, [ENetHost.by_ref, :size_t], :void
  attach_function :enet_host_check_events, [ENetHost.by_ref, ENetEvent.by_ref], :int
  attach_function :enet_host_compress, [ENetHost.by_ref, ENetCompressor.by_ref], :int
  attach_function :enet_host_compress_with_range_coder, [ENetHost.by_ref, ], :int
  attach_function :enet_host_destroy, [ENetHost.by_ref], :void

  # Peer
  attach_function :enet_peer_disconnect, [ENetPeer.by_ref, :uint], :void
  attach_function :enet_peer_disconnect_later, [ENetPeer.by_ref, :uint], :void
  attach_function :enet_peer_disconnect_now, [ENetPeer.by_ref, :uint], :void
  attach_function :enet_peer_dispatch_incoming_reliable_commands, [ENetPeer.by_ref, :pointer, :pointer], :void # FIXME
  attach_function :enet_peer_dispatch_incoming_unreliable_commands, [ENetPeer.by_ref, :pointer, :pointer], :void # FIXME
  attach_function :enet_peer_on_connect, [ENetPeer.by_ref], :void
  attach_function :enet_peer_on_disconnect, [ENetPeer.by_ref], :void
  attach_function :enet_peer_ping, [ENetPeer.by_ref], :void
  attach_function :enet_peer_ping_interval, [ENetPeer.by_ref, :uint], :void
  attach_function :enet_peer_queue_acknowledgement, [ENetPeer.by_ref, :pointer, :ushort], :pointer # FIXME
  attach_function :enet_peer_queue_incoming_command, [ENetPeer.by_ref, :pointer, :pointer, :size_t, :uint, :uint], :pointer # FIXME
  attach_function :enet_peer_queue_outgoing_command, [ENetPeer.by_ref, :pointer, :pointer, :size_t, :uint, :ushort], :pointer # FIXME
  attach_function :enet_peer_receive, [ENetPeer.by_ref, :uchar], :pointer # FIXME
  attach_function :enet_peer_reset, [ENetPeer.by_ref], :void
  attach_function :enet_peer_reset_queues, [ENetPeer.by_ref], :void
  attach_function :enet_peer_send, [ENetPeer.by_ref, :ushort, ENetPacket.by_ref], :int
  attach_function :enet_peer_setup_outgoing_command, [ENetPeer.by_ref, :pointer], :void
  attach_function :enet_peer_throttle, [ENetPeer.by_ref, :uint], :int
  attach_function :enet_peer_throttle_configure, [ENetPeer.by_ref, :uint, :uint, :uint], :void
  attach_function :enet_peer_timeout, [ENetPeer.by_ref, :uint, :uint, :uint], :void
end

pp LibENet.enet_linked_version
LibENet.enet_initialize

addr = LibENet::ENetAddress.new
LibENet.enet_address_set_host(addr, "localhost")
addr[:port] = 3000
pp addr
pp addr[:host]
pp addr[:port]

ptr = LibENet.enet_host_create(addr, 8, 8, 0, 0)
pp ptr
host = LibENet::ENetHost.new(ptr)
pp host
pp host[:total_sent_packets]
pp LibENet.enet_host_service(host, nil, 0)
pp LibENet.enet_host_flush(host)
pp LibENet.enet_host_destroy(host)


LibENet.enet_deinitialize
