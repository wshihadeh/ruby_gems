# frozen_string_literal: true

workers Integer(ENV['WEB_CONCURRENCY'] || 2)
threads_count = Integer(ENV['MAX_THREADS'] || 5)
threads threads_count, threads_count

preload_app!

rackup      DefaultRackup
port        ENV['PORT']     || 3000
environment ENV['RACK_ENV'] || 'development'

root_path = Pathname.new(File.expand_path('..', __dir__))

pidfile "#{root_path}/tmp/puma.pid"
state_path "#{root_path}/tmp/puma.state"
