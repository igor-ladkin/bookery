require 'rails_helper'

RSpec.describe Concert, type: :model do
  describe "validations" do
    it "is not valid with empty title" do
      concert = described_class.new(title: "").tap(&:valid?)
      expect(concert.errors).to have_key(:title)
    end

    it "is not valid with empty starts_at" do
      concert = described_class.new(starts_at: "").tap(&:valid?)
      expect(concert.errors).to have_key(:starts_at)
    end

    it "is not valid with empty sales_open_at" do
      concert = described_class.new(sales_open_at: "").tap(&:valid?)
      expect(concert.errors).to have_key(:sales_open_at)
    end

    it "is not valid with remaining_ticket_count < 0" do
      concert = described_class.new(remaining_ticket_count: -1).tap(&:valid?)
      expect(concert.errors).to have_key(:remaining_ticket_count)
    end
  end
end
