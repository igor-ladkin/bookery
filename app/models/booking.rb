class Booking < ApplicationRecord
  TICKET_LIMIT = 5

  belongs_to :user
  belongs_to :concert
  has_one :payment

  validates :ticket_type, inclusion: { in: ->(booking) { booking.concert&.available_ticket_types || [] } }
  validates :quantity, numericality: {
    greater_than_or_equal_to: 1,
    less_than_or_equal_to: TICKET_LIMIT
  }

  def paid?
    payment.present? && payment.completed?
  end
end
