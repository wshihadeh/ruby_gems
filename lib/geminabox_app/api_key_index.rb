# frozen_string_literal: true

# :nodoc
class ApiKeyIndex
  attr_accessor :key, :username

  def initialize(key, username)
    @key = key
    @username = username
  end

  def save
    payload = { user: @username }
    keys_store[@key] = payload
    ApiKeyIndex.new_index(@key, payload)
  end

  private

  def keys_store
    GeminaboxApp::Store.new(Geminabox.data, 'api_keys')
  end

  class << self
    def find(key)
      payload = keys_store[key]
      return if payload.nil?

      new_index(key, payload)
    end

    def new_index(key, payload)
      payload = {} if payload.nil?
      new(key, payload[:user])
    end

    private

    def keys_store
      GeminaboxApp::Store.new(Geminabox.data, 'api_keys')
    end
  end
end
