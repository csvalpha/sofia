require 'omniauth-oauth2'

module OmniAuth
  module Strategies
    class BananaOauth2 < OmniAuth::Strategies::OAuth2
      # change the class name and the :name option to match your application name
      option :name, :banana

      option :client_options, site: 'http://localhost:4200', authorize_url: '/api/oauth/authorize'

      uid { raw_info['id'] }

      info do
        {
          username: raw_info['username']
        }
      end

      def raw_info
        @raw_info ||= access_token.get('/api/users/me.json').parsed
      end

      # https://github.com/intridea/omniauth-oauth2/issues/81
      def callback_url
        full_host + script_name + callback_path
      end
    end
  end
end
