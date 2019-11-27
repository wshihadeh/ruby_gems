# frozen_string_literal: true

# :nodoc
module GeminaboxApp
  # :nodoc
  module Middleware
    autoload :Common,              'geminabox_app/middleware/common'
    autoload :ApiKey,              'geminabox_app/middleware/api_key'
    autoload :HealthCheck,         'geminabox_app/middleware/health_check'
    autoload :SignUp,              'geminabox_app/middleware/sign_up'
    autoload :ApiGem,              'geminabox_app/middleware/api_gem'
    autoload :WebRequestsLdapAuth,
             'geminabox_app/middleware/web_requests_ldap_auth'
  end
end
