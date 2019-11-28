# frozen_string_literal: true

require 'rack/auth/ldap'

module GeminaboxApp
  module Middleware
    # :nodoc
    class WebRequestsLdapAuth < Rack::Auth::Ldap
      include Common

      def initialize(app, config_options = {})
        super(app, config_options)
      end

      def call(env)
        @request = Rack::Request.new(env)

        return @app.call(env) unless protected?
        return super if upload_form_request?
        return delete_request(env) if delete_request?
        return upload_request(env) if upload_request?

        unauthorized
      end

      private

      def ldap_auth_request(env)
        auth = Rack::Auth::Ldap::Request.new(env)
        return unauthorized unless auth.provided?
        return bad_request unless auth.basic?
        return unauthorized unless valid?(auth)

        env['REMOTE_USER'] = auth.username

        auth
      end

      def delete_request(env)
        auth = ldap_auth_request(env)
        return auth unless auth.is_a? Rack::Auth::Ldap::Request

        gem_name = extract_gem_name
        unless allowed?(gem_name, auth.username)
          return not_allowed(auth.username, gem_name)
        end

        result = @app.call(env)
        GemIndex.remove(gem_name) if result.first == 303 && last_gem?(gem_name)
        result
      end

      def upload_request(env)
        auth = ldap_auth_request(env)
        return auth unless auth.is_a? Rack::Auth::Ldap::Request

        gem_name = extract_gem_from_file_name
        unless allowed?(gem_name, auth.username)
          return not_allowed(auth.username, gem_name)
        end

        result = @app.call(env)
        if GemIndex.new?(gem_name) && result.first == 200
          GemIndex.new(gem_name, auth.username).save
        end
        result
      end

      def upload_form_request?
        @request.get? && @request.path == '/upload'
      end

      def upload_request?
        @request.post? && @request.path == '/upload'
      end

      def delete_request?
        @request.post? && @request.path.match(%r{/gems/.*gem})
      end

      def protected?
        delete_request? ||
          upload_form_request? ||
          upload_request?
      end

      def extract_gem_from_file_name
        @request.params['file'][:filename].slice(/(.*?)-([a-z0-9\.]*)gem/, 1)
      rescue StandardError
        nil
      end

      def extract_gem_name
        @request.path.slice(%r{/gems/(.*?)-([a-z0-9\.]*)gem}, 1)
      rescue StandardError
        nil
      end

      def not_allowed(user, gem)
        msg = 'Access Denied. Ldap user '\
        "#{user} is not allowed to manage #{gem}."
        html_response 401, msg
      end
    end
  end
end
