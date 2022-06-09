require 'rails_helper'

RSpec.describe Booking, type: :model do
  describe "validations" do
    it "is not valid with empty ticket_type" do
      booking = described_class.new(ticket_type: "").tap(&:valid?)
      expect(booking.errors).to have_key(:ticket_type)
    end

    it "is not valid with empty quantity" do
      booking = described_class.new(quantity: "").tap(&:valid?)
      expect(booking.errors).to have_key(:quantity)
    end

    it "is not valid with quantity < 0" do
      booking = described_class.new(quantity: -1).tap(&:valid?)
      expect(booking.errors).to have_key(:quantity)
    end
  end
end
