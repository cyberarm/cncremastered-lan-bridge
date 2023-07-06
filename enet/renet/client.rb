module ENet
  class Client
    Address = Struct.new(:host, :port)

    attr_reader :_peer, :id, :address

    def initialize(peer)
      @_peer = peer

      @id = @_peer[:connect_id]
      @address = Address.new("localhost", 3000)
    end
  end
end
