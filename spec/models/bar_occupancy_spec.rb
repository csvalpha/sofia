require 'rails_helper'

describe BarOccupancy do
  include ActiveSupport::Testing::TimeHelpers

  describe '.enabled?' do
    it 'is true when a token is configured' do
      allow(Rails.application.config.x).to receive(:occupancy_api_token).and_return('secret')

      expect(described_class).to be_enabled
    end

    it 'is false when no token is configured' do
      allow(Rails.application.config.x).to receive(:occupancy_api_token).and_return(nil)

      expect(described_class).not_to be_enabled
    end
  end

  describe '.current' do
    before { allow(Rails).to receive(:cache).and_return(ActiveSupport::Cache::MemoryStore.new) }

    it 'is unavailable when nothing was recorded' do
      expect(described_class.current).to eq(status: 'unavailable')
    end

    it 'returns the count for an active session' do
      described_class.record(session_active: true, count: 12)

      expect(described_class.current).to eq(status: 'open', count: 12)
    end

    it 'is closed for an inactive session' do
      described_class.record(session_active: false, count: 0)

      expect(described_class.current).to eq(status: 'closed')
    end

    it 'is unavailable once the last report has expired' do
      described_class.record(session_active: true, count: 12)

      travel(described_class::EXPIRES_IN + 1.second) do
        expect(described_class.current).to eq(status: 'unavailable')
      end
    end

    it 'still returns the count just before expiry' do
      described_class.record(session_active: true, count: 12)

      travel(described_class::EXPIRES_IN - 1.second) do
        expect(described_class.current).to eq(status: 'open', count: 12)
      end
    end
  end
end
