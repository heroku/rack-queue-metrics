require 'socket'

module Rack
  module QueueMetrics
    class Middleware

      def initialize(app)
        @app = app
        @addr = IPSocket.getaddress(Socket.gethostname).to_s + ':'+ENV['PORT']
        @instrument_name = "rack.queue-metrics"
        @should_notify = should_notify?
        Thread.new {report(1)}
      end

      def call(env)
        return @app.call(env) unless ENV['PORT']
        status, headers, body = @app.call(env)
        notify(raindrops_stats) if @should_notify
        [status, headers, body]
      end

    private

      def report(interval)
        loop do
          $stdout.puts(["measure=#{@instrument_name}",
            "addr=#{@addr}",
            "queue_depth=#{raindrops_stats[:requests][:queued]}"].join(' '))
          sleep(interval)
        end
      end

      def should_notify?
        if defined?(ActiveSupport::Notifications)
          ActiveSupport::Notifications.notifier.listening?(@instrument_name)
        end
      end

      def notify(data)
        ActiveSupport::Notifications.instrument(@instrument_name, data)
      end

      def raindrops_stats
        if defined? Raindrops::Linux.tcp_listener_stats
          stats = Raindrops::Linux.tcp_listener_stats([ '0.0.0.0:'+ENV['PORT'] ])['0.0.0.0:'+ENV['PORT']]
          return { :requests => { :active => stats.active, :queued => stats.queued }}
        else
          return { :requests => { :active => 0, :queued => 0 }}
        end
      end

    end
  end
end
