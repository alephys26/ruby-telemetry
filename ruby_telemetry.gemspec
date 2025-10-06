Gem::Specification.new do |spec|
  spec.name          = "ruby_telemetry"
  spec.version       = "0.1.0"
  spec.summary       = "Telemetry helper for simple counters, gauges and histograms"
  spec.authors       = ["Yash Shrivastava"]
  spec.email         = ["shrivastavayash26@gmail.com"]
  # include typical files for a gem release
  spec.files         = Dir["lib/**/*.rb"] + Dir["examples/**/**"] + ["README.md", "CHANGELOG.md", "LICENSE", "run_demo.rb", "Gemfile", "Rakefile"]
  spec.require_paths = ["lib"]

  # prometheus-client is optional at runtime (the code handles LoadError); keep it as a development/test dependency
  spec.add_development_dependency "prometheus-client", ">= 3.0", "< 4.0"
  spec.add_development_dependency "rack"
  spec.add_development_dependency "rspec"

  spec.homepage = "https://github.com/yourusername/ruby_telemetry"
  spec.license = "MIT"
end