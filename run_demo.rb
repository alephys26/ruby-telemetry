$LOAD_PATH.unshift(File.join(__dir__, 'lib'))
require 'telemetry'

Telemetry.configure do |c|
  c.metrics_prefix = 'demo_prefix'
  c.emitter = Telemetry::Emitter::Console.new
end

m = Telemetry::Method.new('DoThing', 'DemoService')
start = Time.now
sleep 0.01
m.record_latency(start, 'user:123')
m.inc_counter('op')
m.set_gauge(42.5)
puts 'Done'
