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
  end

  describe '#upcoming' do
    let(:past_activity) do
      FactoryBot.create(:activity, start_time: 2.days.ago, end_time: 1.day.ago)
    end

    subject(:future_activity) do
      FactoryBot.create(:activity, start_time: 1.day.from_now, end_time: 2.days.from_now)
    end

    it { expect(Activity.upcoming).to include future_activity }
    it { expect(Activity.upcoming).not_to include past_activity }
  end

  describe '#humanized_time' do
    subject(:activity) do
      FactoryBot.build_stubbed(:activity, start_time: '2017-12-20'.to_date, end_time: '2017-12-21'.to_date)
    end

    it { expect(activity.humanized_start_time).to eq '20 December 2017 00:00' }
    it { expect(activity.humanized_end_time).to eq '21 December 2017 00:00' }
  end
end
