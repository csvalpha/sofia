require 'rails_helper'

describe 'occupancy reader rack-attack safelist' do # rubocop:disable RSpec/DescribeClass
  before { allow(Rails.application.config.x).to receive(:occupancy_api_token).and_return(token) }

  let(:token) { 'secret' }
  let(:safelist) { Rack::Attack.safelists.fetch('occupancy reader') }

  def matched?(path: '/occupancy', method: 'POST', authorization: 'Bearer secret')
    env = Rack::MockRequest.env_for(path, method:, 'HTTP_AUTHORIZATION' => authorization)

    safelist.matched_by?(Rack::Attack::Request.new(env))
  end

  it 'exempts a push with the valid token' do
    expect(matched?).to be_truthy
  end

  it 'does not exempt a wrong token' do
    expect(matched?(authorization: 'Bearer wrong')).to be_falsey
  end

  it 'does not exempt browser polls' do
    expect(matched?(method: 'GET')).to be_falsey
  end

  it 'does not exempt other paths' do
    expect(matched?(path: '/orders')).to be_falsey
  end

  context 'when no token is configured' do
    let(:token) { nil }

    it 'exempts nothing' do
      expect(matched?(authorization: 'Bearer ')).to be_falsey
    end
  end
end
