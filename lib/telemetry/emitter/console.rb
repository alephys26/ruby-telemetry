module Telemetry
  module Emitter
    class Console
      def inc_counter(metric)
        puts "Metric: #{metric}, Value: 1"
      end

      def observe(metric, value)
        puts "Observe Metric: #{metric}, Value: #{value}"
      end

      def set_gauge(metric, value)
        puts "Set Gauge Metric: #{metric}, Value: #{value}"
      end

      def log_info(message)
        puts "INFO: #{message}"
      end

      def log_debug(message)
        puts "DEBUG: #{message}"
      end

      def log_error(message)
        puts "ERROR: #{message}"
      end
    end
  end
end