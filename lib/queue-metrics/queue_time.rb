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
        dyno_start    = (Time.now.to_f * 1000.0).round
        request_start = (env["HTTP_X_REQUEST_START"] || 0).to_i
        request_id    = env["HTTP_HEROKU_REQUEST_ID"]
        report = "at=metric measure=#{@instrument_name} dyno_start=#{dyno_start}"
        report << " request_start=#{request_start} request_start_delta=#{dyno_start - request_start}" if request_start > 0
        report << " request_id=#{request_id}" if request_id
        $stdout.puts report

        notify(:dyno_start => dyno_start, :request_start => request_start, :request_id => request_id) if should_notify?

        env["HTTP_HEROKU_DYNO_START"] = dyno_start

        @app.call(env)
      end
    end
  end
end
