require "rails_helper"

RSpec.describe BookingsMailer, type: :mailer do
  describe "confirmation_email" do
    let(:booking) { Booking.first }
    let(:mail) { BookingsMailer.with(booking: booking).confirmation_email }

    it "renders the headers" do
      expect(mail.subject).to eq("Booking confirmation")
      expect(mail.to).to eq(["to@example.org"])
      expect(mail.from).to eq(["from@example.com"])
    end

    it "renders the body" do
      expect(mail.body.encoded).to match("Sasho")
      expect(mail.body.encoded).to match("Adele")
      expect(mail.body.encoded).to match("tickets are on the way")
    end

    context "when the booking was not paid" do
      before do
        allow(booking).to receive(:paid?).and_return(false)
      end

      it "renders pending payment note" do
        expect(mail.body.encoded).to match("not paid")
      end
    end
  end
end
