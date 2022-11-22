module CncRemasteredLanBridge
  class Net
    class Client
      def self.instance=(i)
        raise "Must be an instance of CncRemasteredLanBridge::Net::Client!" unless i.instance_of?(Client)

        @instance = i
      end

      def self.instance
        @instance
      end

      attr_reader :handler, :url
      attr_accessor :status

      def initialize(handler:, url: "ws://localhost:3000/api/v1/websocket")
        CncRemasteredLanBridge::Net::Client.instance = self

        @handler = handler
        @url = url
        @ws = nil

        @status = false

        raise "No handler was set for #{self.class}" unless @handler
      end

      def connect!
        @status = :connecting

        WebSocket::Client::Simple.connect(@url) do |ws|
          @ws = ws

          ws.on(:open) do
            puts "connected!"
            CncRemasteredLanBridge::Net::Client.instance.status = :connected

            ws.send({ type: :listing }.to_json)
          end

          ws.on(:message) do |msg|
            next if msg.data.empty?

            hash = JSON.parse(msg.data, symbolize_names: true)

            unless CncRemasteredLanBridge::Net::Client.instance.handler.event(hash)
              puts "UNKNOWN message type: #{hash[:type]}"
            end
          end

          ws.on(:close) do |e|
            @ws = nil

            CncRemasteredLanBridge::Net::Client.instance.status = :closed

            p e
            puts e.backtrace
          end

          ws.on(:error) do |e|
            @ws = nil

            CncRemasteredLanBridge::Net::Client.instance.status = :error

            p e
            puts e.backtrace
          end
        end

      rescue => e
        @status = :error

        puts e
        puts e.backtrace
      end

      def write(message)
        @ws&.send(message)
      end

      def closed?
        @status == :closed || @status == :error
      end

      def connecting?
        @status == :connecting
      end

      def connected?
        @status == :connected
      end

      def error?
        @status == :error
      end
    end
  end
end
