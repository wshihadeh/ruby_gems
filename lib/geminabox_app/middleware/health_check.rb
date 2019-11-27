# frozen_string_literal: true

module GeminaboxApp
  module Middleware
    # :nodoc
    class HealthCheck
      include Common

      def initialize(app)
        @app = app
      end

      def call(env)
        case env['PATH_INFO']
        when '/health'
          health_endpoint
        else
          @app.call(env)
        end
      end

      private

      def health_endpoint
        html_response 200, 'OK'
      end
    end
  end
end
