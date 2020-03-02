# frozen_string_literal: true

require 'net/ldap'

module GeminaboxApp
  # :nodoc
  class Ldap
    def initialize(config_path, environment)
      puts config_path
      puts environment
      configs = load_yaml(config_path, environment).transform_keys do |key|
        key.to_sym
      rescue StandardError
        key
      end
      @configs = default_ldap_configs.merge! configs

      @configs[:encryption] = if @configs[:ldaps]
                                { method: :simple_tls }
                              elsif @configs[:starttls]
                                { method: :start_tls,
                                  tls_options: @configs[:tls_options] }.compact
                              end
    end

    def authenticate(username, password)
      conn = ldap_connection
      return false unless conn

      filter = Net::LDAP::Filter.eq(@configs[:username_ldap_attribute], username)
      conn.bind_as(filter: filter, password: password)
    end

    def groups_of(user_dn)
      conn = ldap_connection
      return false unless conn

      filter = @configs[:ldap_group_filter].gsub(/{dn}/, user_dn)
      conn.search(
        base: @configs[:ldap_group_base],
        filter: filter
      ).map(&:cn).flatten.compact
    end

    private

    def ldap_connection
      conn = Net::LDAP.new(
        host: @configs[:hostname],
        port: @configs[:port],
        base: @configs[:basedn],
        encryption: @configs[:encryption]
      )

      if @configs[:auth]
        conn.auth @configs[:rootdn], @configs[:passdn]
        return false unless conn.bind
      end

      conn
    end

    def load_yaml(file, env)
      unless File.exist?(file)
        raise "Could not load ldap configuration. No such file - #{file}"
      end

      ldap_config = YAML.safe_load(ERB.new(IO.read(file)).result, [Symbol])[env]
      if ldap_config.nil?
        raise "Could not load ldap configuration for env #{env}"
      end

      ldap_config
    rescue Psych::SyntaxError => e
      raise "YAML syntax error occurred while parsing #{file}. " \
            'Please note that YAML must be consistently '\
            'indented using spaces. Tabs are not allowed. ' \
            "Error: #{e.message}"
    end

    def default_ldap_configs
      {
        hostname: 'localhost',
        port: 389,
        basedn: 'dc=domain,dc=tld',
        rootdn: '',
        passdn: '',
        auth: true,
        scope: :subtree,
        username_ldap_attribute: 'givenName',
        ldap_group_base: 'ou=group,dc=domain,dc=tld',
        ldap_group_filter: '(&(objectClass=groupOfNames)(member={dn}))',
        ldaps: false,
        starttls: false,
        tls_options: nil
      }
    end
  end
end
