
require 'omniauth/strategies/oauth2'

module OmniAuth
  module Strategies
    class BananaOauth2 < OmniAuth::Strategies::OAuth2
      option :name, 'banana_oauth2'

      option :client_options,
             site: Rails.application.config.x.banana_api_host,
             authorize_url: '/api/oauth/authorize',
             token_url: '/api/oauth/token'

      uid { raw_info['id'] }

      info do
        {
          uid: raw_info['id'],
          username: raw_info['attributes']['username'],
          name: full_name(raw_info),
          avatar_url: raw_info['attributes']['avatar-url'],
          avatar_thumb_url: raw_info['attributes']['avatar-thumb-url'],
          memberships: memberships_from_json(raw_info['relationships']['groups']['data'])
        }
      end

      def raw_info
        headers = { accept: 'application/vnd.csvalpha.nl; version=1' }
        @raw_info ||= JSON.parse(access_token.get('/api/users/me', headers: headers).body)['data']
      end

      # https://github.com/intridea/omniauth-oauth2/issues/81
      def callback_url
        options[:redirect_uri] || (full_host + script_name + callback_path)
      end

      def full_name(raw_info)
        User.full_name_from_attributes(raw_info['attributes']['first-name'],
                                       raw_info['attributes']['last-name-prefix'],
                                       raw_info['attributes']['last-name'])
      end

      def memberships_from_json(json)
        json.map { |membership| membership['id'] }
      end
    end
  end
end
