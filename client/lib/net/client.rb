module CncRemasteredLanBridge
  class Net
    class Client
      def self.instance=(i)
        @instance = i
      end

      def self.instance
        @instance
      end

      attr_reader :handler, :url

      def initialize(handler:, url: "ws://localhost:3000/api/v1/websocket")
        CncRemasteredLanBridge::Net::Client.instance = self

        @handler = handler
        @url = url
        @ws = nil

        raise "No handler was set for #{self.class}" unless @handler
      end

      def connect!
        WebSocket::Client::Simple.connect(@url) do |ws|
          @ws = ws
          ws.on :open do
            puts "connected!"

            ws.send({ type: :listing }.to_json)
          end

          ws.on :message do |msg|
            next if msg.data.empty?

            hash = JSON.parse(msg.data, symbolize_names: true)

            unless CncRemasteredLanBridge::Net::Client.instance.handler.event(hash)
              puts "UNKNOWN message type: #{hash[:type]}"
            end
          end

          ws.on :close do |e|
            @ws = nil

            p e
            puts e.backtrace
          end

          ws.on :error do |e|
            @ws = nil

            p e
            puts e.backtrace
          end
        end
      end

      def write(message)
        @ws&.send(message)
      end

      def closed?
        @ws.nil?
      end
    end
  end
end
