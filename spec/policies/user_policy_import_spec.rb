require 'rails_helper'

describe UserPolicy do
  describe '#import?' do
    subject(:import?) { described_class.new(user, User).import? }

    context 'when treasurer' do
      let(:user) { create(:user, :treasurer) }

      it { expect(import?).to be true }
    end

    context 'when renting manager' do
      let(:user) { create(:user, :renting_manager) }

      it { expect(import?).to be false }
    end

    context 'when main bartender' do
      let(:user) { create(:user, :main_bartender) }

      it { expect(import?).to be false }
    end

    context 'when without roles' do
      let(:user) { create(:user) }

      it { expect(import?).to be false }
    end

    context 'when logged out' do
      let(:user) { nil }

      it { expect(import?).to be_falsey }
    end
  end
end
