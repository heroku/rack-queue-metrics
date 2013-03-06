require 'socket'

module Heroku
  module UnicornMetrics
    class Queue
      
      def initialize(app)
        @app = app
      end

      def call(env)
        return @app.call(env) unless ENV['PORT']

        start_time = Time.now.to_f*1000.0
        stats = raindrops_stats

        status, headers, body = @app.call(env)

        stats[:addr] = IPSocket.getaddress(Socket.gethostname).to_s + ':'+ENV['PORT']
        stats[:queue_time] = headers['X-Request-Start'] ? (start_time - headers['X-Request-Start'].to_f).round : 0

        ActiveSupport::Notifications.instrument("unicorn.metrics.queue", stats)

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