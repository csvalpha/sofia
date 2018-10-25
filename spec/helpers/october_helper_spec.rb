require 'rails_helper'

RSpec.describe OctoberHelper, type: :helper do
  describe '#last_october' do
    it 'returns last years october when before this years october' do
      Timecop.freeze(Time.zone.local(2018, 6)) do
        expect(helper.last_october).to eq Time.zone.local(2017, 10)
      end
    end

    it 'returns this years october when in november or december' do
      Timecop.freeze(Time.zone.local(2018, 11)) do
        expect(helper.last_october).to eq Time.zone.local(2018, 10)
      end
    end
  end
end
