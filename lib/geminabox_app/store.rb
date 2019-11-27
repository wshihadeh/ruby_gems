# frozen_string_literal: true

require 'yaml/store'

module GeminaboxApp
  # :nodoc
  class Store
    def initialize(store_path, store_filename = 'data')
      @store = store_class.new("#{store_path}/#{store_filename}.pstore")
    end

    def [](key)
      @store.transaction { @store.fetch(key.to_sym, nil) }
    end

    def []=(key, value)
      value = { key.to_sym => value } unless value.is_a? Hash
      @store.transaction { @store[key.to_sym] = value }
    end

    def remove(key)
      @store.transaction { @store.delete key.to_sym }
    end

    private

    def store_class
      return YAML::Store if ENV.fetch('STORE_FORMAT', 'text') == 'yaml'

      PStore
    end
  end
end
