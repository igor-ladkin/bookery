class Booking < ApplicationRecord
  belongs_to :user
  belongs_to :concert
  has_one :payment

  validates :ticket_type, inclusion: { in: ->(booking) { booking.concert&.available_ticket_types || [] } }
  validates :quantity, numericality: { greater_than_or_equal_to: 0 }

  def paid?
    payment.present? && payment.completed?
  end
end
