require 'rails_helper'

describe UserPolicy do
  let(:treasurer) { create(:user, :treasurer) }

  describe '#permitted_attributes' do
    subject(:attributes) { described_class.new(treasurer, User.new).permitted_attributes }

    it { expect(attributes).to include :birthday }
  end

  describe '#permitted_attributes_for_update' do
    subject(:attributes) { described_class.new(treasurer, record).permitted_attributes_for_update }

    context 'when record is a manual user' do
      let(:record) { create(:user, :manual) }

      it { expect(attributes).to include :birthday }
    end

    context 'when record is a sofia account user' do
      let(:record) { create(:user, :sofia_account) }

      it { expect(attributes).to include :birthday }
    end

    context 'when record is an amber user' do
      let(:record) { create(:user, :from_amber) }

      it { expect(attributes).not_to include :birthday }
    end
  end

  describe '#permitted_attributes_for_update_with_sofia_account' do
    subject(:attributes) { described_class.new(user, user).permitted_attributes_for_update_with_sofia_account }

    let(:user) { create(:user, :sofia_account) }

    it { expect(attributes).not_to include :birthday }
  end
end
