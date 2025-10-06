require "telemetry/version"
require "telemetry/method"
require "telemetry/emitter/console"
require "telemetry/emitter/noop"
require "telemetry/emitter/prometheus_emitter"
require "telemetry/emitter/exporter_middleware"

module Telemetry
  class << self
    attr_accessor :emitter, :metrics_prefix

    def configure
      yield self
    end

    def init_from_env
      self.metrics_prefix = ENV.fetch("METRICS_PREFIX", "ruby_app_telemetry")
      emitter_name = ENV.fetch("METRICS_EMITTER", "console")
      case emitter_name
      when "console"
        self.emitter = Telemetry::Emitter::Console.new
      when "noop"
        self.emitter = Telemetry::Emitter::Noop.new
      when "prometheus"
        address = ENV.fetch("PROMETHEUS_ADDRESS", ":8081")
        self.emitter = Telemetry::Emitter::PrometheusEmitter.new(address)
      else
        raise "Unknown METRICS_EMITTER: #{emitter_name}"
      end
    end
  end
end

# auto-init from env
Telemetry.init_from_env if defined?(ENV)