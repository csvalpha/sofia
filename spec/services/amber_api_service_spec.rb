require 'rails_helper'

RSpec.describe AmberApiService do
  subject(:service) { described_class.new }

  let(:api_url) { 'https://amber.example.com' }
  let(:client_id) { 'test_client_id' }
  let(:client_secret) { 'test_client_secret' }
  let(:access_token_value) { 'test_access_token_123' }

  before do
    allow(Rails.application.config.x).to receive(:amber_api_url).and_return(api_url)
    allow(Rails.application.config.x).to receive(:amber_client_id).and_return(client_id)
    allow(Rails.application.config.x).to receive(:amber_client_secret).and_return(client_secret)
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

    context 'when token is already cached' do
      before do
        allow(RestClient).to receive(:post).and_return(token_response)
      end

      it 'returns the cached token without making a new request' do
        # First call
        service.access_token
        # Second call
        service.access_token

        expect(RestClient).to have_received(:post).once
      end

      it 'returns the same token value' do
        first_token = service.access_token
        second_token = service.access_token
        expect(first_token).to eq(second_token)
      end
    end

    context 'when API returns an error' do
      before do
        response = double('response', code: 401, body: { error: 'invalid_client' }.to_json)
        allow(RestClient).to receive(:post).and_raise(
          RestClient::Unauthorized.new(response)
        )
      end

      it 'returns nil' do
        expect(service.access_token).to be_nil
      end

      it 'logs the error' do
        allow(Rails.logger).to receive(:error)
        service.access_token
        expect(Rails.logger).to have_received(:error).with(/Failed to obtain Amber API token/)
      end
    end

    context 'when API returns invalid JSON' do
      before do
        allow(RestClient).to receive(:post).and_return('invalid json')
      end

      it 'returns nil' do
        expect(service.access_token).to be_nil
      end

      it 'logs the parse error' do
        allow(Rails.logger).to receive(:error)
        service.access_token
        expect(Rails.logger).to have_received(:error).with(/Failed to obtain Amber API token/)
      end
    end

    context 'when network error occurs' do
      before do
        allow(RestClient).to receive(:post).and_raise(RestClient::ExceptionWithResponse.new)
      end

      it 'returns nil' do
        expect(service.access_token).to be_nil
      end

      it 'logs the network error' do
        allow(Rails.logger).to receive(:error)
        service.access_token
        expect(Rails.logger).to have_received(:error).with(/Failed to obtain Amber API token/)
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
        response = double('response', code: 500, body: 'Internal Server Error')
        allow(RestClient).to receive(:get).and_raise(
          RestClient::InternalServerError.new(response)
        )
      end

      it 'returns an empty array' do
        expect(service.fetch_users).to eq([])
      end

      it 'logs the error' do
        allow(Rails.logger).to receive(:error)
        service.fetch_users
        expect(Rails.logger).to have_received(:error).with(/Failed to fetch users from Amber API/)
      end
    end

    context 'when API returns invalid JSON' do
      before do
        allow(RestClient).to receive(:get).and_return('not valid json')
      end

      it 'returns an empty array' do
        expect(service.fetch_users).to eq([])
      end

      it 'logs the parse error' do
        allow(Rails.logger).to receive(:error)
        service.fetch_users
        expect(Rails.logger).to have_received(:error).with(/Failed to fetch users from Amber API/)
      end
    end

    context 'when authorization fails' do
      before do
        response = double('response', code: 401, body: { error: 'Unauthorized' }.to_json)
        allow(RestClient).to receive(:get).and_raise(
          RestClient::Unauthorized.new(response)
        )
      end

      it 'returns an empty array' do
        expect(service.fetch_users).to eq([])
      end

      it 'logs the authorization error' do
        allow(Rails.logger).to receive(:error)
        service.fetch_users
        expect(Rails.logger).to have_received(:error).with(/Failed to fetch users from Amber API/)
      end
    end

    context 'when network error occurs' do
      before do
        allow(RestClient).to receive(:get).and_raise(RestClient::ExceptionWithResponse.new)
      end

      it 'returns an empty array' do
        expect(service.fetch_users).to eq([])
      end

      it 'logs the network error' do
        allow(Rails.logger).to receive(:error)
        service.fetch_users
        expect(Rails.logger).to have_received(:error).with(/Failed to fetch users from Amber API/)
      end
    end

    context 'when token is not available' do
      before do
        # Make token request fail
        token_response = double('response', code: 401, body: { error: 'invalid_client' }.to_json)
        allow(RestClient).to receive(:post).and_raise(
          RestClient::Unauthorized.new(token_response)
        )

        get_response = double('response', code: 401, body: { error: 'Unauthorized' }.to_json)
        allow(RestClient).to receive(:get).and_raise(
          RestClient::Unauthorized.new(get_response)
        )
      end

      it 'still attempts to fetch users' do
        service.fetch_users
        expect(RestClient).to have_received(:get).with(
          "#{api_url}/api/v1/users?filter[group]=Leden",
          { 'Authorization' => 'Bearer ' }
        )
      end

      it 'returns an empty array' do
        expect(service.fetch_users).to eq([])
      end
    end
  end
end
