# frozen_string_literal: true

module GeminaboxApp
  module Middleware
    # :nodoc
    module Common
      module_function

      def last_gem?(gem)
        path = "#{Geminabox.data}/gems/#{gem}*.gem"
        Dir.glob(path).count.zero?
      end

      def allowed?(gem, username)
        (!gem.nil? && !username.nil?) && (
          (
            (GemIndex.new?(gem) || GemIndex.find(gem).username == username) &&
            User.find(username)&.ldap_groups&.include?('maintainer')
          ) ||
          User.find(username)&.ldap_groups&.include?('adminco')
        )
      end

      def access_denied
        text_response 401, 'HTTP Basic: Access denied.'
      end

      def api_access_denied(body)
        response(401, { 'Content-Type' => 'text/plain' }, body)
      end

      def text_response(status, body)
        response(status, { 'Content-Type' => 'application/text' }, body)
      end

      def html_response(status, body)
        response status,
                 {
                   'Content-Type' => 'text/html;charset=utf-8',
                   'Content-Length' => body.to_s.length
                 },
                 body
      end

      def response(status, headers, body)
        [status,
         headers,
         [body]]
      end
    end
  end
end
