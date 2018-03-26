require 'rails_helper'

RSpec.describe SlackHelper, type: :helper do
  include described_class

  describe '#ping' do
    before do
      allow(notifier).to receive(:ping)
    end
    it do
      ping('Example message')
      expect(notifier).to have_received(:ping).with('Example message')
    end
  end
end
