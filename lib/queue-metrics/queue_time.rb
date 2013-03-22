require 'queue-metrics/notify'

module Rack
  module QueueMetrics
    class QueueTime
      include Notify

      def initialize(app)
        @app             = app
        @instrument_name = "rack.queue-metrics.queue-time"
      end

      def call(env)
        start_time   = Time.now.to_f*1000.0
        request_time = env["HTTP_X_REQUEST_START"] || 0
        request_id   = env["HTTP_HEROKU_REQUEST_ID"]
        notify(stats) if should_notify?
        $stdout.puts "at=metric measure=#{@instrument_name} request_id=#{request_id} request_start=#{env["HTTP_X_REQUEST_START"]} dyno_start=#{start_time}"

        status, headers, body = @app.call(env)
        [status, headers, body]
      end
    end
  end
end
