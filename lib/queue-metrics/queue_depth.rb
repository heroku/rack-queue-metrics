require 'queue-metrics/notify'

module Rack
  module QueueMetrics
    class QueueDepth
      include Notify

      def initialize(app, logger = nil)
        @app             = app
        @addr            = IPSocket.getaddress(Socket.gethostname).to_s + ':'+ENV['PORT'] rescue "unknown"
        @instrument_name = "rack.queue-metrics.queue-depth"
        @logger          = logger
        if @logger.nil?
          @logger = ::Logger.new($stdout)
        end

        interval = (ENV['RACK_QUEUE_METRICS_INTERVAL'] || 5).to_i

        if interval <= 0
          # then call on every request
          @inline = true
          @logger.info "-> rack-queue-metrics starting in inline mode"
        else
          # Do it in a separate thread
          @inline = false
          @logger.info "-> rack-queue-metrics starting in interval mode (#{interval}s)"
          Thread.new {report_loop(interval)}
        end

      end

      def call(env)
        report(env["action_dispatch.request_id"]) if @inline
        return @app.call(env) unless ENV['PORT']
        status, headers, body = @app.call(env)
        [status, headers, body]
      end

    private

      def report_loop(interval)
        loop do
          report
          sleep(interval)
        end
      end

      def report(request_id = nil)
        stats = raindrops_stats
        stats[:addr] = @addr
        notify(stats) if should_notify?
        stats = ["at=info",
                  "addr=#{@addr}",
                  "measure#requests.queued=#{stats[:requests][:queued]}",
                  "measure#requests.active=#{stats[:requests][:active]}"]
        stats << "request_id=#{request_id}" if request_id.present?

        @logger.info(stats.join(' '))
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
