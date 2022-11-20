require "json"
require "securerandom"

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
      CLIENTS << client
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

          member_id = SecureRandom.hex

          ROOMS[hash[:room_name].strip.downcase] = room

          hash[:member_id] = member_id
          hash[:member_name] = hash[:owner_name]

          # Send client's message back verbatium as confirmation
          client.write(hash.to_json)
          room.add_member(owner: true, name: hash[:owner_name], client: client, id: member_id)

          send_listing(client)
        end

      when :join_room
      when :leave_room
        if (room = ROOMS[safe_name(hash[:room_name])])
          if (member = room.members.find { |_, h| h[:id] == hash[:member_id] }&.last)
            if member[:owner]
              broadcast(room, { type: :destroy_room, reason: "Room owner has left." }.to_json)

              ROOMS.delete(safe_name(hash[:room_name]))
            else
              broadcast(room, { type: :leave_room, member_name: member[:name] }.to_json)

              room.members.delete(safe_name(member[:name]))
            end

            CLIENTS.each { |c| send_listing(c) }
          else
            # Member does not belong to room, echo back so that their client can leave
            puts "FAILED TO FIND MEMBER: #{hash[:member_id]} (#{member})"
            client.write(data)
          end
        else
          # Room is dead or ophaned, echo back to client so their client can leave the room
          puts "FAILED TO FIND ROOM: #{hash[:room_name]} (#{room})"
          client.write(data)
        end

      else
        puts "UNKNOWN message type: #{hash[:type]}"
      end
    rescue => e
      puts e
      pp e.backtrace
    end

    def on_close(client)
      ROOMS.each do |room_name, room|
        room.members.each do |member_name, member|
          pp room, hash if member[:client] == client

          if member[:owner]
            broadcast(room, { type: :destroy_room, reason: "Room owner has left." }.to_json)

            ROOMS.delete(safe_name(room.room_name))
          else
            broadcast(room, { type: :leave_room, member_name: member[:name] }.to_json)

            room.members.delete(safe_name(member[:name]))
          end

          CLIENTS.each { |c| send_listing(c) }
        end
      end

      CLIENTS.delete(client)
    rescue => e
      puts e
      pp e.backtrace
    end

    def on_shutdown(client)
      CLIENTS.delete(client)
      client.close if client.open?
    rescue => e
      puts e
      pp e.backtrace
    end

    def on_error(client)
      pp client

      CLIENTS.delete(client)
      client.close if client.open?
    rescue => e
      puts e
      pp e.backtrace
    end

    def broadcast(room, message)
      room.members.each do |_name, hash|
        client = hash[:client]

        if client.open?
          client.write(message)
        end
      end
    end

    def safe_name(name)
      name.strip.downcase
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
