module Rack
  module QueueMetrics
    class L2MetFormatter
      def call(serverity, datetime, progname, msg)
        "at=metric #{msg}\n"
      end
    end
  end
end
