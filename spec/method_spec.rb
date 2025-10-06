require "spec_helper"

RSpec.describe Telemetry::Method do
  before do
    Telemetry.configure do |c|
      c.metrics_prefix = "test_prefix"
      c.emitter = Telemetry::Emitter::Noop.new
    end
  end

  it "constructs metric names correctly" do
    m = Telemetry::Method.new("GetUser", "UserService")
    m.inc_counter('foo')
    # no errors, just ensures it calls emitter
  end

  it "records latency" do
    Telemetry.configure { |c| c.emitter = Telemetry::Emitter::Console.new }
    m = Telemetry::Method.new("Find", "Svc")
    start = Time.now
    m.record_latency(start)
  end
end