require 'omniauth/strategies/oauth2'

module OmniAuth
  module Strategies
    class AmberOauth2 < OmniAuth::Strategies::OAuth2
      option :name, 'amber_oauth2'

      option :client_options,
             site: Rails.application.config.x.amber_api_url.to_s,
             authorize_url: Rails.application.config.x.authorize_url,
             token_url: Rails.application.config.x.token_url

      def authorize_params
        params = super
        params[:scope] = 'public sofia'
        params
      end

      uid { raw_info['id'] }

      info do
        {
          uid: raw_info['id'],
          name: full_name(raw_info),
          email: raw_info['attributes']['email'],
          avatar_thumb_url: raw_info['attributes']['avatar_thumb_url'],
          birthday: raw_info['attributes']['birthday'],
          groups: groups_from_json(raw_info['relationships']['active_groups']['data'])
        }
      end

      def raw_info
        @raw_info ||= JSON.parse(access_token.get(Rails.application.config.x.me_url).body)['data'][0]
      end

      # https://github.com/intridea/omniauth-oauth2/issues/81
      def callback_url
        options[:redirect_uri] || (full_host + script_name + callback_path)
      end

      def full_name(raw_info)
        User.full_name_from_attributes(raw_info['attributes']['first_name'],
                                       raw_info['attributes']['last_name_prefix'],
                                       raw_info['attributes']['last_name'],
                                       raw_info['attributes']['nickname'])
      end

      def groups_from_json(json)
        json.pluck('id')
      end
    end
  end
end
