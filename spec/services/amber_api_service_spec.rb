require 'rails_helper'

RSpec.describe AmberApiService do
  subject(:service) { described_class.new }

  let(:api_url) { 'https://amber.example.com' }
  let(:client_id) { 'test_client_id' }
  let(:client_secret) { 'test_client_secret' }
  let(:access_token_value) { 'test_access_token_123' }

  before do
    allow(Rails.application.config.x).to receive_messages(amber_api_url: api_url, amber_client_id: client_id,
                                                          amber_client_secret: client_secret)

    Rails.cache.clear
  end

  describe '#access_token' do
    let(:token_response) do
      {
        'access_token' => access_token_value,
        'token_type' => 'Bearer',
        'expires_in' => 7200
      }.to_json
    end

    context 'when fetching token for the first time' do
      before do
        allow(RestClient).to receive(:post)
          .with("#{api_url}/api/v1/oauth/token", hash_including(grant_type: 'client_credentials'))
          .and_return(token_response)
      end

      it 'requests a token from the API' do
        expect(service.access_token).to eq(access_token_value)
      end

      it 'makes a POST request to the token endpoint' do
        service.access_token
        expect(RestClient).to have_received(:post).with(
          "#{api_url}/api/v1/oauth/token",
          hash_including(grant_type: 'client_credentials', client_id: client_id, client_secret: client_secret)
        ).once
      end
    end

    context 'when API returns an error' do
      before do
        response = instance_double(RestClient::Response, code: 401, body: { error: 'invalid_client' }.to_json)
        allow(RestClient).to receive(:post).and_raise(
          RestClient::Unauthorized.new(response)
        )
      end

      it 'raises the exception' do
        expect { service.access_token }.to raise_error(RestClient::Unauthorized)
      end

      it 'logs the error before raising' do
        allow(Rails.logger).to receive(:error)
        expect { service.access_token }.to raise_error(RestClient::Unauthorized)
        expect(Rails.logger).to have_received(:error).with(/Failed to obtain OAuth2 provider token/)
      end
    end

    context 'when API returns invalid JSON' do
      before do
        allow(RestClient).to receive(:post).and_return('invalid json')
      end

      it 'raises a JSON parse error' do
        expect { service.access_token }.to raise_error(JSON::ParserError)
      end

      it 'logs the parse error before raising' do
        allow(Rails.logger).to receive(:error)
        expect { service.access_token }.to raise_error(JSON::ParserError)
        expect(Rails.logger).to have_received(:error).with(/Failed to obtain OAuth2 provider token/)
      end
    end

    context 'when network error occurs' do
      before do
        allow(RestClient).to receive(:post).and_raise(RestClient::ExceptionWithResponse.new)
      end

      it 'raises the network error' do
        expect { service.access_token }.to raise_error(RestClient::ExceptionWithResponse)
      end

      it 'logs the network error before raising' do
        allow(Rails.logger).to receive(:error)
        expect { service.access_token }.to raise_error(RestClient::ExceptionWithResponse)
        expect(Rails.logger).to have_received(:error).with(/Failed to obtain OAuth2 provider token/)
      end
    end
  end

  describe '#fetch_users' do
    let(:users_response) do
      {
        'data' => [
          {
            'id' => '1',
            'type' => 'users',
            'attributes' => {
              'first_name' => 'John',
              'last_name' => 'Doe',
              'email' => 'john@example.com'
            }
          },
          {
            'id' => '2',
            'type' => 'users',
            'attributes' => {
              'first_name' => 'Jane',
              'last_name' => 'Smith',
              'email' => 'jane@example.com'
            }
          }
        ]
      }.to_json
    end

    before do
      # Stub the token request
      allow(RestClient).to receive(:post).and_return(
        { 'access_token' => access_token_value }.to_json
      )
    end

    context 'when users are fetched successfully' do
      before do
        allow(RestClient).to receive(:get)
          .with("#{api_url}/api/v1/users?filter[group]=Leden", { 'Authorization' => "Bearer #{access_token_value}" })
          .and_return(users_response)
      end

      it 'returns the users data' do
        users = service.fetch_users
        expect(users).to be_an(Array)
        expect(users.size).to eq(2)
      end

      it 'includes correct user attributes' do
        users = service.fetch_users
        expect(users.first['id']).to eq('1')
        expect(users.first['attributes']['first_name']).to eq('John')
      end

      it 'sends the authorization header' do
        service.fetch_users
        expect(RestClient).to have_received(:get).with(
          "#{api_url}/api/v1/users?filter[group]=Leden",
          { 'Authorization' => "Bearer #{access_token_value}" }
        )
      end
    end

    context 'when API returns an error' do
      before do
        response = instance_double(RestClient::Response, code: 500, body: 'Internal Server Error')
        allow(RestClient).to receive(:get).and_raise(
          RestClient::InternalServerError.new(response)
        )
      end

      it 'raises the exception' do
        expect { service.fetch_users }.to raise_error(RestClient::InternalServerError)
      end

      it 'logs the error before raising' do
        allow(Rails.logger).to receive(:error)
        expect { service.fetch_users }.to raise_error(RestClient::InternalServerError)
        expect(Rails.logger).to have_received(:error).with(/Failed to fetch users from OAuth2 provider/)
      end
    end

    context 'when API returns invalid JSON' do
      before do
        allow(RestClient).to receive(:get).and_return('not valid json')
      end

      it 'raises a JSON parse error' do
        expect { service.fetch_users }.to raise_error(JSON::ParserError)
      end

      it 'logs the parse error before raising' do
        allow(Rails.logger).to receive(:error)
        expect { service.fetch_users }.to raise_error(JSON::ParserError)
        expect(Rails.logger).to have_received(:error).with(/Failed to fetch users from OAuth2 provider/)
      end
    end

    context 'when authorization fails' do
      before do
        response = instance_double(RestClient::Response, code: 401, body: { error: 'Unauthorized' }.to_json)
        allow(RestClient).to receive(:get).and_raise(
          RestClient::Unauthorized.new(response)
        )
      end

      it 'raises the authorization error' do
        expect { service.fetch_users }.to raise_error(RestClient::Unauthorized)
      end

      it 'logs the authorization error before raising' do
        allow(Rails.logger).to receive(:error)
        expect { service.fetch_users }.to raise_error(RestClient::Unauthorized)
        expect(Rails.logger).to have_received(:error).with(/Failed to fetch users from OAuth2 provider/)
      end
    end

    context 'when network error occurs' do
      before do
        allow(RestClient).to receive(:get).and_raise(RestClient::ExceptionWithResponse.new)
      end

      it 'raises the network error' do
        expect { service.fetch_users }.to raise_error(RestClient::ExceptionWithResponse)
      end

      it 'logs the network error before raising' do
        allow(Rails.logger).to receive(:error)
        expect { service.fetch_users }.to raise_error(RestClient::ExceptionWithResponse)
        expect(Rails.logger).to have_received(:error).with(/Failed to fetch users from OAuth2 provider/)
      end
    end

    context 'when token is not available' do
      before do
        # Make token request fail
        token_response = instance_double(RestClient::Response, code: 401, body: { error: 'invalid_client' }.to_json)
        allow(RestClient).to receive(:post).and_raise(
          RestClient::Unauthorized.new(token_response)
        )
      end

      it 'fails when trying to get the token and does not attempt to fetch users' do
        expect { service.fetch_users }.to raise_error(RestClient::Unauthorized)
      end
    end
  end
end
