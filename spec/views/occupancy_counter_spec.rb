require 'rails_helper'

# View specs, because the layout needs built assets and the test image doesn't build them
describe 'occupancy counter' do
  before do
    # These helpers come from the controller, which view specs don't have
    without_partial_double_verification do
      allow(view).to receive(:current_user).and_return(user)
      allow(view).to receive(:policy).with(:occupancy).and_return(instance_double(OccupancyPolicy, index?: visible))
    end
  end

  let(:user) { create(:user) }

  describe 'home page' do
    before do
      assign(:upcoming_activities, [])
      assign(:current_activities, [])
      render template: 'index/index'
    end

    context 'when the policy allows it' do
      let(:visible) { true }

      it { expect(rendered).to include('id="occupancy-counter"', 'data-url="/occupancy"') }
    end

    context 'when the policy does not allow it' do
      let(:visible) { false }

      it { expect(rendered).not_to include('occupancy-counter') }
    end
  end

  describe 'order screen' do
    before do
      view.lookup_context.prefixes << 'activities'
      allow(view).to receive_messages(javascript_include_tag: '', sumup_callback_activity_url: '/callback')
      assign(:activity, create(:activity))
      assign(:users_json, '[]')
      assign(:product_prices_json, '[]')
      assign(:activity_json, '{}')
      render template: 'activities/order_screen'
    end

    context 'when the policy allows it' do
      let(:visible) { true }

      it { expect(rendered).to include('id="occupancy-counter"', 'v-pre') }
    end

    context 'when the policy does not allow it' do
      let(:visible) { false }

      it { expect(rendered).not_to include('occupancy-counter') }
    end
  end
end
