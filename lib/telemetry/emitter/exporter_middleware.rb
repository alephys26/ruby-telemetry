# A simple Rack middleware that exposes /metrics using prometheus-client
begin
  require 'prometheus/client'
  require 'prometheus/client/formats/text'
rescue LoadError
end

module Telemetry
  module Emitter
    class ExporterMiddleware
      def initialize(app, registry: Prometheus::Client.registry)
        @app = app
        @registry = registry
      end

      def call(env)
        if env['PATH_INFO'] == '/metrics'
          body = Prometheus::Client::Formats::Text.marshal(@registry)
    return [200, { 'content-type' => Prometheus::Client::Formats::Text::CONTENT_TYPE }, [body]]
        end

        @app.call(env)
      end
    end
  end
end