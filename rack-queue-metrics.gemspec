# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "queue-metrics/version"

Gem::Specification.new do |s|
  s.name        = "rack-queue-metrics"
  s.version     = Rack::QueueMetrics::VERSION
  s.authors     = ["dominic (Dominic Dagradi)"]
  s.email       = ["dominic@heroku.com"]
  s.homepage    = "http://github.com/heroku/rack-queue-metrics"
  s.summary     = %q{Measure queueing metrics for Rack apps}
  s.description = %q{Measure queueing metrics for Rack apps}

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency 'raindrops'
end