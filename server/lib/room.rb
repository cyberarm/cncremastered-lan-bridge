module CncRemasteredLanBridge
  class Room
    attr_reader :room_name, :owner_name, :members

    def initialize(room_name:, owner_name:, password:)
      @room_name = room_name
      @owner_name = owner_name.strip.downcase
      @password = password

      @members = {}
    end

    def add_member(owner: false, name:, client:, id:)
      if @members[safe_name(name)]
        # FAIL
        return false
      else
        @members[safe_name(name)] = {
          id: id,
          owner: owner,
          name: name,
          client: client
        }
      end

      broadcast(
        { type: :add_member, member_name: name, room_owner: owner }.to_json
      )
    end

    def remove_member(id:, name:)
      if (member = @member[safe_name(name)])
        if member[:id] == id
          @members.delete(safe_name(name))

          if member[:owner]
            broadcast({ type: :destroy_room }.to_json)
          else
            broadcast({ type: :remove_member, name: name }.to_json)
          end
        end
      else
        # FAIL
      end
    end

    def broadcast(message)
      @members.each do |_name, hash|
        client = hash[:client]

        if client.open?
          client.write(message)
        end
      end
    end

    def password?
      !@password.to_s.empty?
    end

    def safe_name(name)
      name.strip.downcase
    end
  end
end
