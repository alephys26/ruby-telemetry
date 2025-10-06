require "time"
module Telemetry
  class Method
    def initialize(method_name, service_name)
      @service = snake(service_name)
      @method = snake(method_name)
      @log_name = "[#{service_name}.#{method_name}]"
      @metrics_prefix = Telemetry.metrics_prefix
      @base = if @metrics_prefix && @metrics_prefix != ""
                "#{@metrics_prefix}.#{@service}.#{@method}"
              else
                "#{@service}.#{@method}"
              end
    end

    def record_latency(start_time, *dimension)
      metric = join_prefix(@base + ".latency", *dimension)
      # record milliseconds like Go implementation
      Telemetry.emitter.observe(metric, ((Time.now - start_time) * 1000.0))
    end

    def log_and_count_error_or_success(err, *dimension)
      if err
        log_and_count_error(err, *dimension)
      else
        log_and_count_success(*dimension)
      end
    end

    def log_and_count_success(*dimension)
      Telemetry.emitter.log_debug("#{@log_name} finished successfully.| dimension: #{dimension}")
      count_success(*dimension)
    end

    def log_and_count_error(err, *dimension)
      Telemetry.emitter.log_error("#{@log_name} failed. Reason: #{err} | dimension: #{dimension}")
      count_error(*dimension)
    end

    def count_request(*dimension)
      metric = join_prefix(@base + ".request", *dimension)
      Telemetry.emitter.inc_counter(metric)
    end

    def count_error(*dimension)
      metric = join_prefix(@base + ".error", *dimension)
      Telemetry.emitter.inc_counter(metric)
    end

    def count_success(*dimension)
      metric = join_prefix(@base + ".success", *dimension)
      Telemetry.emitter.inc_counter(metric)
    end

    def inc_counter(*dimension)
      metric = join_prefix(@base, *dimension)
      Telemetry.emitter.inc_counter(metric)
    end

    def set_gauge(value, *dimension)
      metric = join_prefix(@base, *dimension)
      Telemetry.emitter.set_gauge(metric, value)
    end

    private

    def snake(s)
      s.gsub(/::/, '/').
        gsub(/([A-Z]+)([A-Z][a-z])/,'\\1_\\2').
        gsub(/([a-z\d])([A-Z])/,'\\1_\\2').
        tr("- ", "__").
        downcase
    end

    def join_prefix(prefix, *parts)
      return prefix if parts.nil? || parts.empty?
      ([prefix] + parts.map(&:to_s)).join('.')
    end
  end
end