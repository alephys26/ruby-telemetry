# config.ru for the demo Rack app
$LOAD_PATH.unshift(File.join(__dir__, '..', 'lib'))
require 'telemetry'
require_relative 'app'

# If METRICS_EMITTER=prometheus is set, initialize the PrometheusEmitter which will
# start a small server for /metrics unless you prefer to let the middleware handle it.
Telemetry.init_from_env

use Telemetry::Emitter::ExporterMiddleware
run DemoApp.new
