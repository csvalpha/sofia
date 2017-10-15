class User < ApplicationRecord
  devise :omniauthable, omniauth_providers: [:google_oauth2] # :banana_oauth2
  has_many :orders, dependent: :destroy
  validates :name, presence: true

  def credit
    credit = 0
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
end
