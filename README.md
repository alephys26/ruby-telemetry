# ruby-telemetry

This is a minimal Ruby gem that provides a `Telemetry::Method` helper inspired by the Go package `go-telemetry`.

It supports three emitters chosen via environment variables:
- `console` — prints metric operations to stdout
- `noop` — no-op emitter
- `prometheus` — uses the `prometheus-client` gem and exposes metrics

Environment configuration (optional):

```
export METRICS_EMITTER=prometheus  # console | noop | prometheus
export METRICS_PREFIX=my_app_telemetry
export PROMETHEUS_ADDRESS=:8081
```

Quick example (script)

This example mirrors how the Go `pkg/telemetry` package is used: create a `Method` helper, record requests, latency and success/error counts.

```ruby
require 'telemetry'

# initialize from ENV (auto-called on require; you can call explicitly)
Telemetry.init_from_env

# create a method helper (method name, service name)
m = Telemetry::Method.new('GetUser', 'UserService')

# count a request
m.count_request('path:/users')

# measure latency
start = Time.now
# ... do work ...
sleep 0.02
m.record_latency(start, 'path:/users')

# log error or success and increment counters accordingly
err = nil
m.log_and_count_error_or_success(err, 'path:/users')

# set a gauge
m.set_gauge(42.0, 'connections')
```

Rack exporter example

For web apps, the project includes a complete Rack demo in the `examples/` folder.

Files added:

- `examples/app.rb` — a tiny Rack app that uses `Telemetry::Method` to emit counters, latency and gauges.
- `examples/config.ru` — mounts `Telemetry::Emitter::ExporterMiddleware` and runs the demo app.

Run the demo with the console emitter (default):

```bash
bundle exec rackup examples/config.ru -p 5123
```

Then exercise the app (in another terminal):

```bash
curl http://localhost:5123/      # app endpoint
curl http://localhost:5123/metrics # metrics endpoint (served by middleware)
```

Run the demo with the Prometheus emitter (starts a small server for metrics):

```bash
export METRICS_EMITTER=prometheus
export PROMETHEUS_ADDRESS=:8082  # optional
bundle exec rackup examples/config.ru -p 5123
```

Visit `http://localhost:8082/metrics` (or whichever address you set) to view prometheus-formatted metrics. You can still access the app at `http://localhost:5123/`.

Notes
- The `prometheus-client` gem is optional. If it's not installed the middleware and Prometheus emitter tests are skipped and the middleware will raise a NameError if invoked; install via `bundle add prometheus-client` or add it to your `Gemfile` if you plan to use Prometheus.
- Metric naming follows snake_case for service/method and uses dot-separated suffixes (e.g. `my_app.my_service.my_method.latency`).
- Latency is recorded in milliseconds to match the Go package; when using Prometheus histograms the emitter converts ms to seconds before observing.