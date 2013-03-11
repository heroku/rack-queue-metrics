require 'socket'

module Rack
  module QueueMetrics
    class Middleware

      def initialize(app)
        @addr = IPSocket.getaddress(Socket.gethostname).to_s + ':'+ENV['PORT']
        @app = app
      end

      def call(env)
        return @app.call(env) unless ENV['PORT']

        start_time = Time.now.to_f*1000.0
        stats = raindrops_stats

        status, headers, body = @app.call(env)

        stats[:queue_time] = env["HTTP_X_REQUEST_START"] ? (start_time - env["HTTP_X_REQUEST_START"].to_f).round : 0

        puts "at=metric measure=rack.queue-metrics addr=#{@addr} queue_time=#{stats[:queue_time]} queue_depth=#{stats[:requests][:queued]}"
        ActiveSupport::Notifications.instrument("rack.queue-metrics", stats) if defined?(ActiveSupport::Notifications)

        [status, headers, body]
      end

    private

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
