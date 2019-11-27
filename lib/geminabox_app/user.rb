# frozen_string_literal: true

module GeminaboxApp
  # User Model class
  class User
    attr_accessor :user_name, :api_key, :ldap_groups, :gems

    def initialize(user_name, api_key, ldap_groups = [], gems = [])
      @user_name = user_name
      @api_key = api_key
      @ldap_groups = ldap_groups
      @gems = gems
    end

    def save
      payload = { api_key: @api_key, ldap_groups: @ldap_groups, gems: @gems }
      users_store[@user_name] = payload
      User.new_user(@user_name, payload)
    end

    private

    def users_store
      GeminaboxApp::Store.new(Geminabox.data, 'users')
    end

    class << self
      def exists?(username)
        return true if users_store[username]&.is_a?(Hash)

        false
      end

      def find(username)
        payload = users_store[username]
        return if payload.nil?

        new_user(username, payload)
      end

      def new_user(username, payload)
        return if payload.nil?

        new(username, payload[:api_key], payload[:ldap_groups], payload[:gems])
      end

      private

      def users_store
        GeminaboxApp::Store.new(Geminabox.data, 'users')
      end
    end
  end
end
