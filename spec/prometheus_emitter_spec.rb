require 'spec_helper'

begin
  require 'prometheus/client'
rescue LoadError
  # skip tests if prometheus-client not installed
end

RSpec.describe Telemetry::Emitter::PrometheusEmitter do
  it 'creates and registers counters, gauges and histograms' do
    pending('prometheus-client gem not installed') unless defined?(Prometheus::Client)

    Telemetry.configure do |c|
      c.emitter = Telemetry::Emitter::PrometheusEmitter.new(':0')
      c.metrics_prefix = 'spec'
    end

    m = Telemetry::Method.new('T', 'S')
    m.inc_counter('x')
    m.set_gauge(3.14, 'g')
    m.record_latency(Time.now)

    # ensure registry contains metrics
    expect(Prometheus::Client.registry.exist?(:spec_s_t_x)).to be true
  end
end