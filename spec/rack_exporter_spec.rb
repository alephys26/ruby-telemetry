require 'spec_helper'

begin
  require 'rack'
  require 'prometheus/client'
rescue LoadError
end

RSpec.describe Telemetry::Emitter::ExporterMiddleware do
  it 'responds to /metrics' do
    unless defined?(Rack) && defined?(Prometheus::Client)
      skip 'rack or prometheus-client not installed'
    end

    app = ->(env) { [200, {'Content-Type' => 'text/plain'}, ['OK']] }
    mw = Telemetry::Emitter::ExporterMiddleware.new(app)

  status, headers, body = mw.call({ 'PATH_INFO' => '/metrics' })
  expect(status).to eq(200)
  # Rack 3 uses lowercase header keys; be tolerant of either form
  content_type = headers['Content-Type'] || headers['content-type']
  expect(content_type).to include('text/plain')
  end
end