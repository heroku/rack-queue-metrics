# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "heroku/version"

Gem::Specification.new do |s|
  s.name        = "heroku-unicorn-metrics"
  s.version     = Heroku::UnicornMetrics::VERSION
  s.authors     = ["dominic (Dominic Dagradi)"]
  s.email       = ["dominic@heroku.com"]
  s.homepage    = "http://github.com/heroku/heroku-unicorn-metrics"
  s.summary     = %q{Additional metrics for Heroku apps using Unicorn}
  s.description = %q{Additional metrics for Heroku apps using Unicorn}

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_runtime_dependency 'unicorn'
end