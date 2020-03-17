# frozen_string_literal: true

require 'rack/auth/ldap'

module GeminaboxApp
  module Middleware
    # :nodoc
    class SignUp < Rack::Auth::Ldap
      include Common

      def initialize(app, ldap, config_options = {})
        @ldap = ldap
        super(app, config_options)
      end

      def call(env)
        request = Rack::Request.new(env)
        return @app.call(env) unless sign_up_request?(request)

        auth = ldap_auth_request(env)
        return auth unless auth.is_a? Rack::Auth::Ldap::Request

        api_key = create_or_find_user_api_key(
          env['REMOTE_USER'],
          env['REMOTE_USER_DN']
        )

        html_response(200, "<h1>Your Api Key is : #{api_key}</h1>")
      rescue StandardError
        unauthorized
      end

      private

      def ldap_auth_request(env)
        auth = Rack::Auth::Ldap::Request.new(env)
        return unauthorized unless auth.provided?
        return bad_request unless auth.basic?

        valid_user = valid?(auth)
        return unauthorized unless valid_user

        env['REMOTE_USER'] = auth.username
        env['REMOTE_USER_DN'] = valid_user.first.dn

        auth
      end

      def create_or_find_user_api_key(username, user_dn)
        raise if username.nil?

        ldap_groups = @ldap.groups_of(user_dn)
        user = User.find(username) || User.new(username, SecureRandom.uuid)
        user.ldap_groups = ldap_groups
        user.save

        ApiKeyIndex.new(user.api_key, username).save
        user.api_key
      end

      def sign_up_request?(request)
        request.path.match %r{^/signup}
      end
    end
  end
end
