require 'queue-metrics/notify'

module Rack
  module QueueMetrics
    class AppTime
      include Notify

      def initialize(app)
        @app             = app
        @instrument_name = "rack.queue-metrics.app-time"
      end

      def call(env)
        app_start        = (Time.now.to_f * 1000.0).round
        request_id       = env["HTTP_HEROKU_REQUEST_ID"]
        middleware_start = (env["MIDDLEWARE_START"] || 0).to_i
        report = "at=metric measure=#{@instrument_name}.start app_start=#{app_start}"
        report << " middleware_delta=#{app_start - middleware_start}" if middleware_start > 0
        report << " request_id=#{request_id}" if request_id
        $stdout.puts report

        status, headers, response = @app.call(env)

        app_end = (Time.now.to_f * 1000.0).round
        report  = "at=metric measure=#{@instrument_name}.end app_end=#{app_end}"
        report << " app_delta=#{app_end - app_start}"
        report << " request_id=#{request_id}" if request_id
        $stdout.puts report

        notify(:app_end => app_end, :app_start => app_start, :request_id => request_id) if should_notify?

        [status, headers, response]
      end
    end
  end
end
