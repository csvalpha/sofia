
require 'omniauth/strategies/oauth2'

module OmniAuth
  module Strategies
    class BananaOauth2 < OmniAuth::Strategies::OAuth2
      option :name, 'banana_oauth2'

      option :client_options,
             site: 'http://localhost:3000',
             authorize_url: '/oauth/authorize',
             token_url: '/oauth/token'

      uid { raw_info['id'] }

      info do
        {
          uid: raw_info['id'],
          username: raw_info['attributes']['username'],
          name: raw_info['attributes']['username']
        }
      end

      def raw_info
        @raw_info ||= JSON.parse(access_token.get('/users/me', headers: { accept: 'application/vnd.csvalpha.nl; version=1' }).body)['data']
      end

      # https://github.com/intridea/omniauth-oauth2/issues/81
      def callback_url
        options[:redirect_uri] || (full_host + script_name + callback_path)
      end
    end
  end
end
