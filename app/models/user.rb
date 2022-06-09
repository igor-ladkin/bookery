class User < ApplicationRecord
  validates :name, presence: true, uniqueness: true

  has_many :bookings
  has_many :payments
end
