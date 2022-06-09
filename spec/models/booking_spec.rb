require 'rails_helper'

RSpec.describe Booking, type: :model do
  describe "validations" do
    let(:concert) { Concert.find_by! title: "Imagine Dragons" }

    it "is not valid with empty ticket_type" do
      booking = build_booking ticket_type: ""
      expect(booking.errors).to have_key(:ticket_type)
    end

    it "is not valid with non-existing ticket_type" do
      booking = build_booking ticket_type: "premium", concert: concert
      expect(booking.errors).to have_key(:ticket_type)
    end

    it "is not valid with empty quantity" do
      booking = build_booking quantity: ""
      expect(booking.errors).to have_key(:quantity)
    end

    it "is not valid with quantity < 0" do
      booking = build_booking quantity: -1
      expect(booking.errors).to have_key(:quantity)
    end
  end

  private

  def build_booking(params)
    described_class.new(params).tap(&:valid?)
  end
end
