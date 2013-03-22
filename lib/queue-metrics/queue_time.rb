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
        dyno_start    = Time.now.to_f * 1000.0
        request_start = (env["HTTP_X_REQUEST_START"] || 0).to_i
        request_id    = env["HTTP_HEROKU_REQUEST_ID"]
        notify(stats) if should_notify?
        $stdout.puts "at=metric measure=#{@instrument_name} request_id=#{request_id} request_start=#{request_start} dyno_start=#{dyno_start} queue_time=#{dyno_start - request_start}"

        @app.call(env)
      end
    end
  end
end
