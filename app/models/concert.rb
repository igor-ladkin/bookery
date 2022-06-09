class Concert < ApplicationRecord
  serialize :available_ticket_types, Array

  validates :title, :starts_at, :sales_open_at, presence: true
  validates :remaining_ticket_count, numericality: { greater_than_or_equal_to: 0 }
  validates :available_ticket_types, presence: true
  validate :validate_available_ticket_types

  def self.available_ticket_types
    %w[standard premium vip]
  end

  def sold_out?
    remaining_ticket_count.zero?
  end

  private

  def validate_available_ticket_types
    unless available_ticket_types.all? { |type| Concert.available_ticket_types.include?(type) }
      errors.add(:available_ticket_types, "must be one of #{Concert.available_ticket_types.join(', ')}")
    end
  end
end
