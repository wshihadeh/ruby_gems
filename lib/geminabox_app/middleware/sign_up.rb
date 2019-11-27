# frozen_string_literal: true

require 'rack/auth/ldap'

module GeminaboxApp
  module Middleware
    # :nodoc
    class SignUp < Rack::Auth::Ldap
      include Common

      def initialize(app, config_options = {})
        super(app, config_options)
      end

      def call(env)
        request = Rack::Request.new(env)
        return @app.call(env) unless sign_up_request?(request)

        result = super
        api_key = create_or_find_user_api_key(env['REMOTE_USER'])

        return result if api_key.nil? || result.first == 401

        html_response(200, "<h1>Your Api Key is : #{api_key}</h1>")
      end

      private

      def create_or_find_user_api_key(user)
        return if user.nil?

        user = User.find(user) || User.new(user, SecureRandom.uuid).save
        ApiKeyIndex.new(user.api_key, user).save
        user.api_key
      end

      def sign_up_request?(request)
        request.path.match %r{^/signup}
      end
    end
  end
end
