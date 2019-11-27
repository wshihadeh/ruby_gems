# frozen_string_literal: true

# Supress default rackup logging middleware
# \ --quiet

require './config/application'

run App.new
