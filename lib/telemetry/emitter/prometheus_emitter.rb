begin
  require 'prometheus/client'
  require 'prometheus/client/formats/text'
rescue LoadError
  # prometheus-client is optional for console/noop use
end

module Telemetry
  module Emitter
    class PrometheusEmitter
      def initialize(address)
        @registry = Prometheus::Client.registry
        @counters = {}
        @gauges = {}
        @histograms = {}
        @address = address
        start_server_if_possible
      end

      def inc_counter(metric)
        counter = (@counters[metric] ||= create_counter(metric))
        counter.increment
      end

      def observe(metric, value)
        hist = (@histograms[metric] ||= create_histogram(metric))
        hist.observe(value / 1000.0) # convert ms to seconds
      end

      def set_gauge(metric, value)
        g = (@gauges[metric] ||= create_gauge(metric))
        g.set(value)
      end

      def log_info(message); puts "INFO: #{message}"; end
      def log_debug(message); puts "DEBUG: #{message}"; end
      def log_error(message); puts "ERROR: #{message}"; end

      private

      def start_server_if_possible
        # If Rack is available we won't start a dedicated server here.
        return unless defined?(Prometheus::Client)

        # Try to start a minimal WEBrick server if address provided like :8081
        begin
          require 'webrick'
          host, port = parse_address(@address)

          server = WEBrick::HTTPServer.new(:Port => port, :BindAddress => host, :Logger => WEBrick::Log.new(STDOUT, WEBrick::Log::WARN), :AccessLog => [])
          server.mount_proc '/metrics' do |req, res|
            res.content_type = Prometheus::Client::Formats::Text::CONTENT_TYPE
            res.body = Prometheus::Client::Formats::Text.marshal(@registry)
          end

          Thread.new { server.start }
        rescue Exception => e
          puts "Failed to start metrics server: #{e}"
        end
      end

      def parse_address(addr)
        # support formats like ':8081' or '0.0.0.0:8081'
        if addr.start_with?(':')
          ['0.0.0.0', addr[1..-1].to_i]
        else
          parts = addr.split(':')
          [parts[0], parts[1].to_i]
        end
      end

      def create_counter(metric)
        name = sanitize_metric(metric)
        if @registry.exist?(name.to_sym)
          m = @registry.get(name.to_sym)
          return m if m.type == :counter
        end

        c = Prometheus::Client::Counter.new(name.to_sym, docstring: metric)
        @registry.register(c)
        c
      end

      def create_gauge(metric)
        name = sanitize_metric(metric)
        if @registry.exist?(name.to_sym)
          m = @registry.get(name.to_sym)
          return m if m.type == :gauge
        end

        g = Prometheus::Client::Gauge.new(name.to_sym, docstring: metric)
        @registry.register(g)
        g
      end

      def create_histogram(metric)
        name = sanitize_metric(metric)
        if @registry.exist?(name.to_sym)
          m = @registry.get(name.to_sym)
          return m if m.type == :histogram
        end

        h = Prometheus::Client::Histogram.new(name.to_sym, docstring: metric)
        @registry.register(h)
        h
      end

      def sanitize_metric(metric)
        # Prometheus metric names must match [a-zA-Z_:][a-zA-Z0-9_:]*
        s = metric.to_s.gsub(/[^a-zA-Z0-9_:]/, '_')
        s = "m_#{s}" unless s =~ /^[a-zA-Z_:]/
        s
      end
    end
  end
end