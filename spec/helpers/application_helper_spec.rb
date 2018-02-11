require 'rails_helper'

RSpec.describe ApplicationHelper, type: :helper do
  describe '#flash_class' do
    it { expect(flash_class('notice')).to eq 'alert-info' }
    it { expect(flash_class('success')).to eq 'alert-success' }
    it { expect(flash_class('error')).to eq 'alert-danger' }
    it { expect(flash_class('alert')).to eq 'alert-warning' }
  end
end
