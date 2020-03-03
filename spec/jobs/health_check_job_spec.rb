require 'rails_helper'

RSpec.describe HealthCheckJob, type: :job do
  describe '#perform' do
    let(:job) { described_class.perform_now(:test) }
    let(:hc_id) { 'test-id' }
    let(:http) { class_double('HTTP') }
    let(:fake_http) { instance_double(FakeHTTP) }

    before do
      allow(Rails.application.config.x).to receive(:healthcheck_ids).and_return({ 'test': hc_id })

      stub_const('HTTP', fake_http)
      allow(fake_http).to receive(:get)
      job
    end

    context 'when with configured hc_id' do
      it do
        expect(fake_http).to have_received(:get).with(
          'https://hc-ping.com/test-id'
        )
      end
    end

    context 'when with unknown hc_id' do
      let(:hc_id) { nil }

      it { expect(fake_http).not_to have_received(:get) }
    end
  end
end
