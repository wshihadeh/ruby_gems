# frozen_string_literal: true

# :nodoc
class App
  def initialize
    @app = Rack::Builder.new do
      use Rack::Session::Pool, expire_after: 1000
      use Rack::Protection
      use GeminaboxApp::Middleware::HealthCheck
      use GeminaboxApp::Middleware::SignUp, App.ldap,
          file: "#{App.root}/config/ldap.yml"
      use GeminaboxApp::Middleware::WebRequestsLdapAuth,
          file: "#{App.root}/config/ldap.yml"
      use GeminaboxApp::Middleware::ApiKey, App.ldap
      use GeminaboxApp::Middleware::ApiGem

      map '/' do
        run Geminabox::Server
      end
    end
  end

  def call(env)
    @app.call(env)
  end

  class << self
    def root
      Pathname.new(File.expand_path('..', __dir__))
    end

    def env
      ENV.fetch('RACK_ENV', 'development')
    end

    def ldap
      @ldap ||= GeminaboxApp::Ldap.new("#{App.root}/config/ldap.yml", App.env)
    end
  end
end
