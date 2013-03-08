# Rack Queue Metrics

Report on queued connections in any Rack-based server using [Raindrops](http://raindrops.bogomips.org/) and the [Raindrops::Linux](http://raindrops.bogomips.org/Raindrops/Linux.html) features. 

## Usage

First, add `rack-queue-metrics` to your Gemfile:

```
gem 'rack-queue-metrics'
```

### Rails

You're done! If you want to instrument queue metrics beyond the default output, you can subscribe to the `unicorn.metrics.queue` notifcation in your Rails app. For example, to print queue information to your logs, add the following to `config/initializers/notifcations.rb:

```
# config/initializers/notifications.rb
ActiveSupport::Notifications.subscribe(/unicorn.metrics.queue/) do |*args|
  event = ActiveSupport::Notifications::Event.new(*args)
  payload = event.payload

  addr = payload[:addr]
  active = payload[:requests][:active]
  queued = payload[:requests][:queued]
  queue_time = payload[:queue_time]

  puts "STATS addr=#{addr} active=#{active} queued=#{queued} queue_time=#{queue_time} "
end
```

For more information, see the [ActiveSupport::Notification](http://api.rubyonrails.org/classes/ActiveSupport/Notifications.html) docs.

### Sinatra/Rack Apps

Include the `Raindrops` and `Rack::QueueMetrics` middleware in your application's config.ru:

```
  # config.ru
  use Raindrops::Middleware
  use Rack::QueueMetrics::Middleware
```

### Output

With every request, `rack-queue-metrics` will output a log line with the the following format:

```
at=metric measure=rack.queue-metrics addr=10.10.10.90:5000 queue_time=0 queue_depth=0
```

## Notifications

The following information is sent in the notification payload:

* `requests[:active]`: Number of requests currently being processed by Unicorn at the start of the request
* `requests[:queued]`: Number of requests waiting to be processed at the start of the request
* `queue_time`: Amount of time the current request spent in the queue
* `addr`: Address of the dyno processing the request