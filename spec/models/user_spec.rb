require 'rails_helper'

RSpec.describe User, type: :model do
  subject(:user) { build_stubbed(:user) }

  describe '#valid' do
    it { expect(user).to be_valid }

    context 'when without a name' do
      subject(:user) { build_stubbed(:user, name: nil) }

      it { expect(user).not_to be_valid }
    end

    context 'when with invalid email' do
      subject(:user) { build_stubbed(:user, email: 'not_an_valid_email') }

      it { expect(user).not_to be_valid }
    end

    context 'when deactivating with credit' do
      subject(:user) { create(:user, deactivated: true) }

      before do
        create(:order_with_items, user:)
      end

      it { expect(user).not_to be_valid }
    end
  end

  describe '.in_amber' do
    context 'when in amber' do
      subject(:user) { create(:user, provider: 'amber_oauth2') }

      before { user }

      it { expect(described_class.in_amber).to include user }
    end

    context 'when not in amber' do
      subject(:user) { create(:user, provider: 'another_provider') }

      before { user }

      it { expect(described_class.in_amber).not_to include user }
    end
  end

  describe '.sofia_account' do
    context 'when sofia_account' do
      subject(:user) { create(:user, :sofia_account) }

      before { user }

      it { expect(described_class.sofia_account).to include user }
    end

    context 'when not sofia_account' do
      subject(:user) { create(:user, provider: 'another_provider') }

      before { user }

      it { expect(described_class.sofia_account).not_to include user }
    end

    context 'when without email' do
      subject(:user) { build(:user, :sofia_account, email: nil) }

      before { build(:sofia_account, user:) }

      it { expect(user).not_to be_valid }
    end

    context 'when with valid email' do
      subject(:user) { build(:user, :sofia_account, email: 'valid@email.com') }

      before { build(:sofia_account, user:) }

      it { expect(user).to be_valid }
    end
  end

  describe '.manual' do
    context 'when manual created' do
      subject(:user) { create(:user, provider: nil) }

      before { user }

      it { expect(described_class.manual).to include user }
    end

    context 'when created via provider' do
      subject(:user) { create(:user, provider: 'another_provider') }

      before { user }

      it { expect(described_class.manual).not_to include user }
    end
  end

  describe '.treasurer' do
    context 'when treasurer' do
      subject(:user) { create(:user) }

      let(:treasurer_role) { create(:role, role_type: :treasurer) }

      before { create(:roles_users, user:, role: treasurer_role) }

      it { expect(described_class.treasurer).to include user }
    end

    context 'when not treasurer' do
      it { expect(described_class.treasurer).not_to include user }
    end
  end

  describe '.active / .deactivated / .not_activated' do
    context 'when active' do
      subject(:user) { create(:user) }

      it { expect(described_class.active).to include user }
      it { expect(described_class.not_activated).not_to include user }
      it { expect(described_class.deactivated).not_to include user }
    end

    context 'when deactivated' do
      subject(:user) { create(:user, deactivated: true) }

      it { expect(described_class.active).not_to include user }
      it { expect(described_class.not_activated).not_to include user }
      it { expect(described_class.deactivated).to include user }
    end

    context 'when not activated' do
      subject(:user) { create(:user, :sofia_account) }

      it { expect(described_class.active).not_to include user }
      it { expect(described_class.not_activated).to include user }
      it { expect(described_class.deactivated).not_to include user }
    end
  end

  describe '#credit' do
    subject(:user) { create(:user) }

    let(:order) { create(:order, user:) }
    let(:product_price) { create(:product_price, price_list: order.activity.price_list, price: 1.23) }

    before do
      create(:order_row, order:, product: product_price.product, product_count: 1)
    end

    it { expect(user.credit).to eq(-1.23) }
  end

  describe '#roles' do
    context 'when with a role' do
      subject(:user) { create(:user) }

      let(:role) { create(:role) }

      before do
        create(:roles_users, role:, user:)
      end

      it { expect(user.roles).to match_array [role] }
    end

    context 'when with a destroyed role' do
      subject(:user) { create(:user) }

      let(:role) { create(:role) }
      let(:roles_users) { create(:roles_users, role:, user:) }

      before do
        roles_users
        roles_users.destroy
      end

      it { expect(user.roles).not_to match_array [role] }
    end
  end

  describe '#avatar_thumb_or_default_url' do
    context 'when with avatar thumb url' do
      subject(:user) { create(:user, avatar_thumb_url: '/test.png') }

      it { expect(user.avatar_thumb_or_default_url).to eq "#{Rails.application.config.x.amber_api_url}/test.png" }
    end

    context 'when without avatar thumb url' do
      subject(:user) { create(:user) }

      it { expect(user.avatar_thumb_or_default_url).to eq '/images/avatar_thumb_default.png' }
    end
  end

  describe '#age' do
    context 'when without birthday' do
      it { expect(user.age).to be_nil }
    end

    context 'when birthday did not pass this year' do
      let(:user) { build(:user, birthday: (1.day.ago - 2.years)) }

      it { expect(user.age).to eq 2 }
    end

    context 'when birthday did pass this year' do
      let(:user) { build(:user, birthday: (1.day.from_now - 2.years)) }

      it { expect(user.age).to eq 1 }
    end
  end

  describe '#minor' do
    context 'when without age' do
      it { expect(user.minor).to be false }
    end

    context 'when 18 or older' do
      let(:user) { build(:user, birthday: 18.years.ago - 1.day) }

      it { expect(user.minor).to be false }
    end

    context 'when younger than 18' do
      let(:user) { build(:user, birthday: (18.years.ago + 1.day)) }

      it { expect(user.minor).to be true }
    end
  end

  describe '#treasurer?' do
    context 'when with treasurer role' do
      subject(:user) { create(:user) }

      let(:role) { create(:role, role_type: :treasurer) }

      before do
        create(:roles_users, role:, user:)
      end

      it { expect(user.treasurer?).to be true }
    end

    context 'when without treasurer role' do
      subject(:user) { create(:user) }

      it { expect(user.treasurer?).to be false }
    end
  end

  describe '#main_bartender?' do
    context 'when with main_bartender role' do
      subject(:user) { create(:user) }

      let(:role) { create(:role, role_type: :main_bartender) }

      before do
        create(:roles_users, role:, user:)
      end

      it { expect(user.main_bartender?).to be true }
    end

    context 'when without main_bartender role' do
      subject(:user) { create(:user) }

      it { expect(user.main_bartender?).to be false }
    end
  end

  describe '#update_role' do
    context 'when getting new roles' do
      subject(:user) { create(:user, :from_amber) }

      let(:role) { create(:role) }

      before do
        user.update_role([role.group_uid])
      end

      it { expect(user.roles).to include role }
    end

    context 'when losing roles' do
      subject(:user) { create(:user) }

      let(:role) { create(:role) }

      before do
        user.update_role([role.group_uid])
        user.update_role([])
      end

      it { expect(user.roles).not_to include role }
    end
  end

  describe 'full_name_from_attributes' do
    context 'when with all attributes' do
      it { expect(described_class.full_name_from_attributes('first', 'middle', 'last', 'nick')).to eq 'first (nick) middle last' }
    end

    context 'when without middle name and nickname' do
      it { expect(described_class.full_name_from_attributes('first', '', 'last', '')).to eq 'first last' }
    end
  end

  describe 'calculate_spendings' do
    let(:user) { create(:user) }

    let(:product_price) { build(:product_price, price: 2.00) }
    let(:price_list) { build(:price_list, product_price: [product_price]) }
    let(:activity) { build(:activity, price_list:) }

    let(:default_order) { { products: [product_price.product], activity:, user: } }

    let(:order) do
      create(:order_with_items, default_order.merge(created_at: 4.weeks.ago))
    end

    let(:second_order) do
      create(:order_with_items, default_order.merge(created_at: 1.week.ago))
    end

    let(:third_order) do
      create(:order_with_items, default_order.merge(user:, created_at: Time.zone.now))
    end

    before do
      order
      second_order
      third_order
    end

    context 'when without date supplied' do
      subject(:spendings_hash) { described_class.calculate_spendings }

      it { expect(spendings_hash[user.id]).to eq 6 }
    end

    context 'when with from date' do
      subject(:spendings_hash) { described_class.calculate_spendings(from: 2.weeks.ago) }

      it { expect(spendings_hash[user.id]).to eq 4 }
    end

    context 'when with to date' do
      subject(:spendings_hash) { described_class.calculate_spendings(to: 2.days.ago) }

      it { expect(spendings_hash[user.id]).to eq 4 }
    end

    context 'when with from and to date' do
      subject(:spendings_hash) { described_class.calculate_spendings(from: 2.weeks.ago, to: 2.days.ago) }

      it { expect(spendings_hash[user.id]).to eq 2 }
    end

    context 'when with wrong date' do
      subject(:spendings_hash) { described_class.calculate_spendings(from: 2.days.from_now, to: 2.days.ago) }

      it { expect(spendings_hash[user.id]).to be_nil }
    end

    context 'when on specific date' do
      subject(:spendings_hash) do
        described_class.calculate_spendings(
          from: Time.zone.local(2018, 6, 1),
          to: Time.zone.local(2018, 6, 23)
        )
      end

      let(:included_date) { Time.zone.local(2018, 6, 22) }
      let(:excluded_date) { Time.zone.local(2018, 6, 23) }

      let(:order) { create(:order_with_items, default_order.merge(created_at: included_date)) }
      let(:second_order) { create(:order_with_items, default_order.merge(created_at: excluded_date)) }
      let(:third_order) { create(:order_with_items, default_order.merge(created_at: excluded_date + 1.day)) }

      it { expect(spendings_hash[user.id]).to eq order.order_total }
    end
  end

  describe 'calculate_credits' do
    let(:user) { create(:user) }

    subject(:credits_hash) { described_class.calculate_credits }

    context 'when without orders or credit_mutations' do
      before { user }

      it { expect(credits_hash[user.id]).to eq 0 }
    end

    context 'when with data' do
      let(:product_price) { build(:product_price, price: 2.18) }
      let(:price_list) { build(:price_list, product_price: [product_price]) }
      let(:activity) { build(:activity, price_list:) }

      context 'without orders' do
        let(:credit_mutation) { create(:credit_mutation, user:, amount: 20) }

        before do
          credit_mutation
        end

        it { expect(credits_hash[user.id]).to eq credit_mutation.amount }
      end

      context 'without credit_mutations' do
        let(:order) do
          build(:order_with_items, products: [product_price.product], activity:, user:)
        end

        before do
          order
        end

        it { expect(credits_hash[user.id]).to eq order.order_total }
      end

      context 'when with both' do
        let(:order) do
          build(:order_with_items, products: [product_price.product], activity:, user:)
        end
        let(:credit_mutation) { create(:credit_mutation, user:, amount: 20) }

        before do
          credit_mutation
        end

        it { expect(credits_hash[user.id]).to eq credit_mutation.amount - order.order_total }
      end
    end
  end

  describe 'destroy' do
    context 'with sofia_account' do
      subject(:user) { create(:user, :sofia_account) }

      before do
        create(:sofia_account, user:)
        user.destroy
      end

      it { expect(SofiaAccount.count).to eq 0 }
    end
  end

  describe '#archive!' do
    context 'with sofia_account' do
      subject(:user) { create(:user, :sofia_account) }

      let(:nil_attributes) do
        %w[avatar_thumb_url email birthday]
      end

      before do
        create(:sofia_account, user:)
        user.archive!
        user.reload
      end

      it { expect(user.archive!).to be true }
      it { expect(user.name).to eq "Gearchiveerde gebruiker #{user.id}" }
      it { expect(user.deactivated).to be true }
      it { expect(user.versions).to be_empty }
      it { expect { user.archive! }.not_to(change(user, :id)) }
      it { expect { user.archive! }.not_to(change(user, :uid)) }
      it { expect { user.archive! }.not_to(change(user, :provider)) }
      it { expect { user.archive! }.not_to(change(user, :sofia_account)) }
      it { expect(SofiaAccount.count).to eq 1 }

      it do
        nil_attributes.each do |attribute|
          expect(user[attribute]).to be_nil
        end
      end
    end
  end

  describe '#before_save' do
    context 'with sofia_account' do
      subject(:user) { create(:user, :sofia_account) }

      it { expect(user.activation_token).not_to be_nil }

      it do
        expect(user.activation_token_valid_till).not_to be_nil
        expect(user.activation_token_valid_till.day).to eq 5.days.from_now.day
      end
    end

    context 'without sofia_account' do
      subject(:user) { create(:user) }

      it { expect(user.activation_token).to be_nil }
      it { expect(user.activation_token_valid_till).to be_nil }
    end
  end

  describe '#after_save' do
    context 'when deactivated upon creation' do
      subject(:user) { build(:user, deactivated: true) }

      it do
        expect(user).to receive(:archive!)
        user.save
      end
    end

    context 'when deactivated after update' do
      subject(:user) { create(:user, deactivated: false) }

      before { user.deactivated = true }

      it do
        expect(user).to receive(:archive!)
        user.save
      end
    end

    context 'when deactivated and not changed' do
      subject(:user) { create(:user, deactivated: true) }

      before { user.email = 'valid@email.com' }

      it do
        expect(user).not_to receive(:archive!)
        user.save
      end
    end

    context 'when not deactivated upon creation' do
      subject(:user) { build(:user, deactivated: false) }

      it do
        expect(user).not_to receive(:archive!)
        user.save
      end
    end

    context 'when not deactivated after update' do
      subject(:user) { create(:user, deactivated: true) }

      before { user.deactivated = false }

      it do
        expect(user).not_to receive(:archive!)
        user.save
      end
    end
  end

  describe '#after_create' do
    context 'with sofia_account' do
      subject(:user) { build(:user, :sofia_account) }

      after do
        clear_enqueued_jobs
      end

      it do
        user.save
        expect(UserMailer).to send_email(:account_creation_email, :deliver_later, user)
      end
    end

    context 'without sofia_account' do
      subject(:user) { build(:user) }

      after do
        clear_enqueued_jobs
      end

      it do
        expect(UserMailer).not_to receive(:account_creation_email)
        user.save
      end
    end
  end
end
