require 'logger'
require 'queue-metrics/l2met_formatter'
require 'queue-metrics/notify'

module Rack
  module QueueMetrics
    class AppTime
      include Notify

      def initialize(app, logger = nil)
        @app             = app
        @instrument_name = "rack.queue-metrics.app-time"
        @logger          = logger
        if @logger.nil?
          @logger = ::Logger.new($stdout)
          @logger.formatter = L2MetFormatter.new
        end
      end

      def call(env)
        app_start        = (Time.now.to_f * 1000.0).round
        request_id       = env["HTTP_HEROKU_REQUEST_ID"]
        middleware_start = (env["MIDDLEWARE_START"] || 0).to_i
        middleware_delta = nil
        report = "measure=#{@instrument_name}.start app_start=#{app_start}"
        if middleware_start > 0
          middleware_delta = app_start - middleware_start
          report << " middleware_delta=#{middleware_delta}"
        end
        report << " request_id=#{request_id}" if request_id
        @logger.info report

        status, headers, response = @app.call(env)

        app_end   = (Time.now.to_f * 1000.0).round
        app_delta = app_end - app_start
        report  = "measure=#{@instrument_name}.end app_end=#{app_end}"
        report << " app_delta=#{app_delta}"
        report << " request_id=#{request_id}" if request_id
        @logger.info report

        notify(:app_end => app_end, :app_start => app_start, :app_delta => app_delta, :middleware_delta => middleware_delta, :request_id => request_id) if should_notify?

        [status, headers, response]
      end
    end
  end
end
