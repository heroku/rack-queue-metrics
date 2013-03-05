require 'socket'

module Heroku
  module UnicornMetrics
    class QueueTime
      ADDR = IPSocket.getaddress(Socket.gethostname).to_s+':'+ENV['PORT']

      def initialize(app)
        @app = app
      end

      def call(env)
        stats = tcp_stats
        request_start = Time.now.to_f*1000.0

        status, headers, body = @app.call(env)

        if headers['X-Request-Start']
          queue_time = (request_start - headers['X-Request-Start'].to_f).round
        else
          queue_time = 0
        end

        request_time = (Time.now.to_f*1000.0 - request_start).round
        puts "STATS addr=#{ADDR} conns_active=#{stats[:active]} conns_queued=#{stats[:queued]} queue_time=#{queue_time} request_time=#{request_time}"

        [status, headers, body]
      end

    private

      def tcp_stats
        if defined? Raindrops::Linux.tcp_listener_stats
          stats = Raindrops::Linux.tcp_listener_stats([ '0.0.0.0:'+ENV['PORT'] ])['0.0.0.0:'+ENV['PORT']]
          return { :active => stats.active, :queued => stats.queued }     
        else
          return { :active => 0, :queued => 0 }     
        end
      end

    end
  end
end