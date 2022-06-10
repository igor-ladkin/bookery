class Concert < ApplicationRecord
  SUPPORTED_TICKET_TYPES = %w[standard premium vip]

  serialize :available_ticket_types, Array

  validates :title, :starts_at, :sales_open_at, presence: true
  validates :remaining_ticket_count, numericality: { greater_than_or_equal_to: 0 }
  validates :available_ticket_types, presence: true
  validate :validate_available_ticket_types

  def sold_out?
    remaining_ticket_count.zero?
  end

  private

  def validate_available_ticket_types
    unless available_ticket_types.all? { _1.in? SUPPORTED_TICKET_TYPES }
      errors.add(:available_ticket_types, "must be one of #{SUPPORTED_TICKET_TYPES.join(', ')}")
    end
  end
end
