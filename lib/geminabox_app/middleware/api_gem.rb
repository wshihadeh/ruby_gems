# frozen_string_literal: true

require 'rack/auth/ldap'

module GeminaboxApp
  module Middleware
    # :nodoc
    class ApiGem
      include Common

      def initialize(app)
        @app = app
      end

      def call(env)
        request = Rack::Request.new(env)
        if add_gem_request?(request)
          return add_gem_request(env['HTTP_AUTHORIZATION'], request, env)
        end
        if yank_gem_request?(request)
          return yank_gem_request(env['HTTP_AUTHORIZATION'], request, env)
        end

        @app.call(env)
      end

      private

      def yank_gem_request(api_key, request, env)
        key = ApiKeyIndex.find(api_key)
        return invalid_api_key unless key

        gem_name = request['gem_name']
        return not_allowed(gem_name) unless allowed?(gem_name, key.username)

        result = @app.call(env)
        GemIndex.remove(gem_name) if result.first == 200 && last_gem?(gem_name)
        result
      end

      def add_gem_request(api_key, request, env)
        key = ApiKeyIndex.find(api_key)
        return invalid_api_key unless key

        gem_name = extract_gem_name(request, env)
        return not_allowed(gem_name) unless allowed?(gem_name, key.username)

        result = @app.call(env)
        if GemIndex.new?(gem_name) && result.first == 200
          GemIndex.new(gem_name, key.username).save
        end
        result
      end

      def extract_gem_name(request, env)
        gem = Geminabox::IncomingGem.new(request.body)
        gem_name = gem.spec.name
        env['rack.input'] = gem.gem_data
        gem_name
      end

      def invalid_api_key
        api_access_denied 'Access Denied. Api_key invalid or missing.'
      end

      def not_allowed(gem)
        msg = "Access Denied. Api_key is now allowed to manage #{gem}."
        api_access_denied msg
      end

      def add_gem_request?(request)
        request.post? && request.path == '/api/v1/gems'
      end

      def yank_gem_request?(request)
        request.delete? && request.path == '/api/v1/gems/yank'
      end
    end
  end
end
