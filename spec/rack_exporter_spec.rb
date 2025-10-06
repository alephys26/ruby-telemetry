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
    expect(headers['Content-Type']).to include('text/plain')
  end
end