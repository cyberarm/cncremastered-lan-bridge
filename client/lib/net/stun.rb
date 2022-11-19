module CncRemasteredLanBridge
  class Net
    class STUN
      DEFAULT_PORT = 3478
      STUN_INTERVAL = 10_000 # ms

      attr_reader :address, :port

      def initialize(port:, stun_host:, stun_port: DEFAULT_PORT)
        @socket = UDPSocket.new
        @socket.setsockopt(Socket::SOL_SOCKET, Socket::SO_REUSEADDR, true)
        @socket.bind("0.0.0.0", port)

        @socket.connect(stun_host, stun_port)

        @last_stun = -STUN_INTERVAL
        @stunned = false

        @address = ""
        @port = 0
      end

      def update
        return unless monotonic_time - @last_stun >= STUN_INTERVAL

        @last_stun = monotonic_time

        @socket.send("STUN", 0)

        readable, _writable, _error = IO.select([@socket], [], [])

        if readable.size.positive?
          data, _addrinfo = readable.first.recvfrom(1024)
          puts "STUN RESPONSE: #{data}"

          @address, @port = data.split(":")
          @stunned = true
        else
          @socket.close
        end
      end

      def stunned?
        @stunned
      end

      def closed?
        @socket&.closed?
      end

      def monotonic_time
        Process.clock_gettime(Process::CLOCK_MONOTONIC, :millisecond)
      end
    end
  end
end
