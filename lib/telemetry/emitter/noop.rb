module Telemetry
  module Emitter
    class Noop
      def inc_counter(metric); end
      def observe(metric, value); end
      def set_gauge(metric, value); end
      def log_info(message); end
      def log_debug(message); end
      def log_error(message); end
    end
  end
end