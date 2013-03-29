require 'logger'
require 'queue-metrics/l2met_formatter'
require 'queue-metrics/notify'

module Rack
  module QueueMetrics
    class QueueTime
      include Notify

      def initialize(app, logger = nil)
        @app             = app
        @instrument_name = "rack.queue-metrics.queue-time"
        @logger          = logger
        if @logger.nil?
          @logger = ::Logger.new($stdout)
          @logger.formatter = L2MetFormatter.new
        end
      end

      def call(env)
        middleware_start    = (Time.now.to_f * 1000.0).round
        request_start       = (env["HTTP_X_REQUEST_START"] || 0).to_i
        request_id          = env["HTTP_HEROKU_REQUEST_ID"]
        request_start_delta = nil
        report = "measure=#{@instrument_name} middleware_start=#{middleware_start}"
        if request_start > 0
          request_start_delta = middleware_start - request_start
          report << " request_start=#{request_start} request_start_delta=#{request_start_delta}"
        end
        report << " request_id=#{request_id}" if request_id
        @logger.info report

        notify(:middleware_start => middleware_start, :request_start => request_start, :request_start_delta => request_start_delta, :request_id => request_id) if should_notify?

        env["MIDDLEWARE_START"] = middleware_start

        @app.call(env)
      end
    end
  end
end
