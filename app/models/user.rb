class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  after_create do
    stripe_customer = Stripe::Customer.create(email: email)
    # stripe_customer_id = stripe_customer.id
    # update(stripe_customer_id: stripe_customer_id)
  end

  def active?
    return false unless subscription_ends_at.present?
    subscription_ends_at > Time.zone.now
  end
end