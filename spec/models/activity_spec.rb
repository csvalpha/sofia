require 'rails_helper'

RSpec.describe Activity, type: :model do
  subject(:activity) { FactoryBot.build_stubbed(:activity) }

  describe '#valid' do
    it { expect(activity).to be_valid }

    context 'when without a title' do
      subject(:activity) { FactoryBot.build_stubbed(:activity, title: nil) }

      it { expect(activity).not_to be_valid }
    end

    context 'when without a price list' do
      subject(:activity) { FactoryBot.build_stubbed(:activity, price_list: nil) }

      it { expect(activity).not_to be_valid }
    end

    context 'when without a start time' do
      subject(:activity) { FactoryBot.build_stubbed(:activity, start_time: nil) }

      it { expect(activity).not_to be_valid }
    end

    context 'when without an end time' do
      subject(:activity) { FactoryBot.build_stubbed(:activity, end_time: nil) }

      it { expect(activity).not_to be_valid }
    end

    context 'when without a created by' do
      subject(:activity) { FactoryBot.build_stubbed(:activity, created_by: nil) }

      it { expect(activity).not_to be_valid }
    end

    context 'when start time is after end time' do
      subject(:activity) { FactoryBot.build_stubbed(:activity, start_time: Time.zone.now + 1.second, end_time: Time.zone.now ) }

      it { expect(activity).not_to be_valid }
    end
  end

  describe 'cannot alter an activity after a month' do
    context 'when within a month' do
      subject(:activity) { FactoryBot.build(:activity) }

      it {expect(activity.update_attributes(title: 'a new one')).to eq true}
    end

    context 'when after a month' do
      subject(:activity) { FactoryBot.build(:activity, :closed) }

      it {expect(activity.update_attributes(title: 'a new one')).to eq false}
    end

  end

  describe '#close_date' do
    subject(:activity) { FactoryBot.build(:activity) }
    it { expect(activity.close_date).to eq activity.end_time + 1.month}
  end

  describe '.upcoming' do
    let(:past_activity) do
      FactoryBot.create(:activity, start_time: 2.days.ago, end_time: 1.day.ago)
    end

    subject(:future_activity) do
      FactoryBot.create(:activity, start_time: 1.day.from_now, end_time: 2.days.from_now)
    end

    it { expect(Activity.upcoming).to include future_activity }
    it { expect(Activity.upcoming).not_to include past_activity }
  end
end
