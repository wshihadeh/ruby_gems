# frozen_string_literal: true

# :nodoc
class GemIndex
  attr_accessor :gem, :username

  def initialize(gem, username)
    @gem = gem
    @username = username
  end

  def save
    payload = { user: @username }
    gem_store[@gem] = payload
    GemIndex.new_index(@gem, payload)
  end

  private

  def gem_store
    GeminaboxApp::Store.new(Geminabox.data, 'gems')
  end

  class << self
    def new?(gem)
      gem_store[gem].nil? ? true : false
    end

    def remove(gem)
      gem_store.remove(gem)
    end

    def find(gem)
      payload = gem_store[gem]
      return if payload.nil?

      new_index(gem, payload)
    end

    def new_index(gem, payload)
      payload = {} if payload.nil?
      new(gem, payload[:user])
    end

    private

    def gem_store
      GeminaboxApp::Store.new(Geminabox.data, 'gems')
    end
  end
end
