require 'rails_helper'

RSpec.describe ApplicationHelper, type: :helper do
  describe '#flash_class' do
    it { expect(flash_class('notice')).to eq 'alert-info' }
    it { expect(flash_class('success')).to eq 'alert-success' }
    it { expect(flash_class('error')).to eq 'alert-danger' }
    it { expect(flash_class('alert')).to eq 'alert-warning' }
  end

  describe '#remove_empty' do
    context 'when with nested hash' do
      let(:hash) { { a: '1', b: '', c: { a: '4', b: '' } } }

      it { expect(remove_empty(hash.to_h)).to eq({ a: '1', c: { a: '4' } }) }
    end
  end
end
