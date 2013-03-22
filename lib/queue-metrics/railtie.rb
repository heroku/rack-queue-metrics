module Rack
  module QueueMetrics
    class RackQueueRailtie < Rails::Railtie
      initializer "rack_queue_railtie.configure_rails_initialization" do |app|
        app.middleware.use Rack::QueueMetrics::QueueTime
        app.middleware.use Raindrops::Middleware
        app.middleware.use Rack::QueueMetrics::QueueDepth
      end
    end
  end
end
