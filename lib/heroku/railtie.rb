module Heroku
  module UnicornMetrics
    class UnicornMetricsRailtie < Rails::Railtie
      initializer "my_railtie.configure_rails_initialization" do |app|
        app.middleware.use Raindrops::Middleware
        app.middleware.use Heroku::UnicornMetrics::Queue
      end
    end
  end
end