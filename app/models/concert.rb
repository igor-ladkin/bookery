class Concert < ApplicationRecord
  validates :title, :starts_at, :sales_open_at, presence: true
  validates :remaining_ticket_count, numericality: { greater_than_or_equal_to: 0 }
end
