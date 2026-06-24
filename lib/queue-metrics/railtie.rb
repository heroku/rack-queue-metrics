module Rack
  module QueueMetrics
    class RackQueueRailtie < Rails::Railtie
      initializer "rack_queue_railtie.configure_rails_initialization" do |app|
        app.middleware.use Rack::QueueMetrics::QueueTime, Rails.logger
        app.middleware.use Raindrops::Middleware
        app.middleware.use Rack::QueueMetrics::QueueDepth, Rails.logger
        app.middleware.use Rack::QueueMetrics::AppTime, Rails.logger
      end
    end
  end
end
