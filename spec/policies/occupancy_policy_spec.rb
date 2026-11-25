require 'rails_helper'

describe OccupancyPolicy do
  describe '#index?' do
    subject(:index?) { described_class.new(user, :occupancy).index? }

    context 'with a configured token' do
      before { allow(BarOccupancy).to receive(:enabled?).and_return(true) }

      context 'when logged in without roles' do
        let(:user) { create(:user) }

        it { expect(index?).to be true }
      end

      context 'when logged out' do
        let(:user) { nil }

        it { expect(index?).to be false }
      end
    end

    context 'without a configured token' do
      before { allow(BarOccupancy).to receive(:enabled?).and_return(false) }

      let(:user) { create(:user, :treasurer) }

      it { expect(index?).to be false }
    end
  end
end
