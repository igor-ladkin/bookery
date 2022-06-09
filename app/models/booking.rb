class Booking < ApplicationRecord
  belongs_to :user
  belongs_to :concert

  validates :ticket_type, presence: true
  validates :quantity, numericality: { greater_than_or_equal_to: 0 }

  enum state: {
    pending: "pending",
    paid: "paid",
    cancelled: "cancelled"
  }
end
