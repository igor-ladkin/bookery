class Booking < ApplicationRecord
  belongs_to :user
  belongs_to :concert

  validates :ticket_type, inclusion: { in: ->(booking) { booking.concert&.available_ticket_types || [] } }
  validates :quantity, numericality: { greater_than_or_equal_to: 0 }

end
