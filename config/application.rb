# frozen_string_literal: true

require 'bundler/setup'
require 'rubygems'
require 'geminabox'
require 'securerandom'

Bundler.require :default, ENV.fetch('RACK_ENV', 'development')

$LOAD_PATH.push File.expand_path('../lib', __dir__)

autoload :GeminaboxApp,          'geminabox_app'
autoload :App,                   'app'

Dir[File.expand_path('initialize/*.rb', __dir__)].sort.each do |file|
  require file
end
