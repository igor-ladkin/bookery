require 'rails_helper'

RSpec.describe User, type: :model do
  describe "validations" do
    it "is not valid with empty name" do
      user = described_class.new(name: "").tap(&:valid?)
      expect(user.errors).to have_key(:name)
    end

    it "is not valid if name is not unique" do
      user = described_class.create(name: "chester")
      user2 = described_class.new(name: "chester").tap(&:valid?)

      expect(user2.errors).to have_key(:name)
    end
  end
end
