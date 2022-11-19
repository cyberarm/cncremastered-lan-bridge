require "socket"
require "English"

module CncRemasteredLanBridge
  class STUNServer
    DEFAULT_PORT = 3478

    def initialize(port: DEFAULT_PORT)
      @socket = UDPSocket.new
      @socket.bind("0.0.0.0", port)

      @running = true

      run!
    end

    def run!
      puts "Running proto STUN server"
      while @running
        readable, _writable, _error = IO.select([@socket])

        if readable.size.positive?
          data, addrinfo = readable.first.recvfrom(1024)

          # FIXME: require this string to be at least 000.000.000:65355 (17) characters long
          return if data != "STUN"

          @socket.send("#{addrinfo[3]}:#{addrinfo[1]}", 0, addrinfo[3], addrinfo[1])
        end
      end
    end
  end
end

if $PROGRAM_NAME == __FILE__
  CncRemasteredLanBridge::STUNServer.new
end
