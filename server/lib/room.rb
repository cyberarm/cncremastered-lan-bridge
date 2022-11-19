module CncRemasteredLanBridge
  class Room
    attr_reader :room_name, :owner_name, :members

    def initialize(room_name:, owner_name:, password:)
      @room_name = room_name
      @owner_name = owner_name.strip.downcase
      @password = password

      @members = {}
    end

    def add_member(name:, address:, port:)
      if @members[safe_name(name)]
        # FAIL
      else
        @members[safe_name(name)] = {
          name: name,
          address: address,
          port: port
        }
      end

      @room_changed = true
    end

    def remove_member(name:, address:)
      if (member = @member[safe_name(name)])
        if member[:address] == address
          @members.delete(safe_name(name))

          if safe_name(member[:name]) == @owner_name
            # KILL ROOM if owner leaves?
            room_changed!
          else
            room_changed!
          end
        end
      else
        # FAIL
      end
    end

    def room_changed!
      @room_changed = true
    end

    def room_changed?
      @room_changed
    end

    def password?
      !@password.to_s.empty?
    end

    def safe_name(name)
      name.strip.downcase
    end
  end
end
