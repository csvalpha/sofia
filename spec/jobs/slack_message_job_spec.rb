require 'rails_helper'

RSpec.describe SlackMessageJob do
  describe '#perform' do
    let(:job) { described_class.new }

    before do
      allow(job).to receive(:ping)
      job.perform('Example message')
    end

    it { expect(job).to have_received(:ping).with('Example message') }
  end
end
