class User < ApplicationRecord
  devise :omniauthable, omniauth_providers: [:banana_oauth2]
  has_many :orders, dependent: :destroy
  has_many :credit_mutations, dependent: :destroy
  validates :name, presence: true
  validates :uid, uniqueness: true

  scope :in_banana, (-> { where(provider: 'banana_oauth2') })

  def credit
    credit = credit_mutations.map(&:amount).sum
    orders.each do |order|
      credit -= order.order_total
    end
    credit
  end

  def self.from_omniauth(auth)
    where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
      user.name = auth[:info][:name]
    end
  end

  def self.full_name_from_attributes(first_name, last_name_prefix, last_name)
    [first_name, last_name_prefix, last_name].reject(&:blank?).join(' ')
  end
end
