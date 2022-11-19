require "json"

require_relative "lib/room"
require_relative "stun_server"

module CncRemasteredLanBridge
  module WebSocketRouter
    HTTP_RESPONSE = [
      200,
      {
        "Content-Type" => "text/html",
        "Content-Length" => "77"
      },
      [
        "Please connect using WebSockets or SSE (send messages only using WebSockets)."
      ]
    ]

    WS_RESPONSE = [0, {}, []].freeze

    def self.call(env)
      if (env["rack.upgrade?".freeze])
        env["rack.upgrade".freeze] = WebSocketClient.new
        return WS_RESPONSE
      end

      HTTP_RESPONSE
    end
  end

  class WebSocketClient
    CLIENTS = []

    ROOMS = {}

    def on_open(client)
      pp client
    rescue => e
      puts e
    end

    def on_message(client, data)
      hash = JSON.parse(data, symbolize_names: true)

      pp hash

      case hash[:type].to_sym
      when :listing
        CLIENTS << client unless CLIENTS.find { |c| c == client }

        send_listing(client)

      when :create_room
        if (room = ROOMS[hash[:room_name].strip.downcase])
          # FAIL

          client.write({ type: :create_room, error: "Room name not unique!" }.to_json)
        else
          room = Room.new(
            room_name: hash[:room_name].strip,
            owner_name: hash[:owner_name].strip,
            password: hash[:password]
          )

          # room.add_member(name: hash[:owner_name], address: hash[:address], port: hash[:port])

          ROOMS[hash[:room_name].strip.downcase] = room

          # Send client's message back verbatium as confirmation
          client.write(data)
          send_listing(client)
        end

      when :join_room
      when :leave_room
      else
        puts "UNKNOWN message type: #{hash[:type]}"
      end
    rescue => e
      puts e
    end

    def on_shutdown(client)
      CLIENTS.delete(client)
      client.close unless client.closed?
    rescue => e
      puts e
    end

    def on_error(client)
      CLIENTS.delete(client)
      client.close unless client.closed?
    rescue => e
      puts e
    end

    def send_listing(client)
      rooms = []

      ROOMS.each do |key, room|
        rooms << {
          room_name: room.room_name,
          room_owner: room.owner_name,
          room_password: room.password?
        }
      end

      puts "SENDING rooms: #{rooms}"

      client.write({ type: :listing, rooms: rooms }.to_json)
    end
  end
end

Thread.new do
  CncRemasteredLanBridge::STUNServer.new
end
