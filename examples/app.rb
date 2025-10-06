# A tiny Rack app that uses Telemetry::Method to emit metrics
$LOAD_PATH.unshift(File.join(__dir__, '..', 'lib'))
require 'telemetry'

# Default to console emitter so running this example without extra gems works
Telemetry.configure do |c|
  c.metrics_prefix = ENV.fetch('METRICS_PREFIX', 'demo_app')
  c.emitter = Telemetry::Emitter::Console.new
end

class DemoApp
  def initialize
    @method = Telemetry::Method.new('Handle', 'DemoApp')
  end

  def call(env)
    path = env['PATH_INFO'] || '/'
    # count request and simulate latency
    @method.count_request(path)
    start = Time.now
    # simulate work
    sleep(rand * 0.01)
    @method.record_latency(start, path)

    # randomly set a gauge and sometimes error
    @method.set_gauge(rand * 10, 'workers')

    if rand < 0.1
      err = RuntimeError.new('simulated error')
      @method.log_and_count_error(err, path)
  return [500, {'content-type' => 'text/plain'}, ["Error\n"]]
    end

    @method.log_and_count_success(path)
  [200, {'content-type' => 'text/plain'}, ["OK\n"]]
  end
end

# When used with config.ru the `run` directive is called from the Rack builder file.
