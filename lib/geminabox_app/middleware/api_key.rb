# frozen_string_literal: true

module GeminaboxApp
  module Middleware
    # :nodoc
    class ApiKey
      include Common

      def initialize(app, ldap)
        @app = app
        @ldap = ldap
      end

      def call(env)
        case env['PATH_INFO']
        when '/api/v1/api_key'
          process_api_key_request(Rack::Auth::Basic::Request.new(env))
        else
          @app.call(env)
        end
      end

      private

      def process_api_key_request(request)
        username = request.credentials.first
        password = request.credentials.last
        validate(username, @ldap.authenticate(username, password))
      rescue StandardError
        access_denied
      end

      def validate(username, authenticated_user)
        if authenticated_user

          ldap_groups = @ldap.groups_of(authenticated_user.first.dn)
          user = User.find(username) || User.new(username, SecureRandom.uuid)
          user.ldap_groups = ldap_groups
          user.save

          key = user.api_key
          ApiKeyIndex.new(key, username).save
          return api_key key
        end
        access_denied
      end

      def api_key(key)
        text_response 200, key
      end
    end
  end
end
