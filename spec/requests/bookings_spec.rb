require 'rails_helper'

RSpec.describe "Bookings", type: :request do
  describe "POST /create" do
    shared_examples "a bad request" do
      it "returns http unprocessable entity" do
        request
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "doesn't create a booking" do
        expect { request }.not_to change { user.bookings.count }
      end

      it "doesn't reduce the available tickets for a concert" do
        expect { request }.not_to change { concert.reload.remaining_ticket_count }
      end

      it "does not send confirmation email" do
        expect { request }
          .not_to have_enqueued_job(ActionMailer::MailDeliveryJob)
          .on_queue("default")
          .with 'BookingsMailer', 'confirmation_email', 'deliver_now', params: { booking: a_kind_of(Booking) }, args: []
      end
    end

    shared_examples "a placed booking" do
      it "returns http redirect" do
        request
        expect(response).to have_http_status(:redirect)
      end

      it "creates a booking for a user" do
        expect { request }.to change { user.bookings.count }.by(1)
      end

      it "reduces the available tickets for a concert" do
        expect { request }.to change { concert.reload.remaining_ticket_count }.by(-2)
      end

      it "sends confirmation email" do
        expect { request }
          .to have_enqueued_job(ActionMailer::MailDeliveryJob)
          .on_queue("default")
          .with 'BookingsMailer', 'confirmation_email', 'deliver_now', params: { booking: a_kind_of(Booking) }, args: []
      end
    end

    subject(:request) { post concert_bookings_path(concert), params: { booking: booking_params } }

    let(:user) { User.first }
    let(:concert) { Concert.find_by! title: "Imagine Dragons" }
    let(:booking_params) do
      {
        concert_id: concert.id,
        ticket_type: "standard",
        quantity: 2,
      }
    end

    before do
      allow(Analytics).to receive(:track)
    end

    context "happy path" do
      include_examples "a placed booking"

      it "adds successful flash message" do
        request
        expect(flash[:notice]).to eq("Your booking has been created!")
      end

      it "charges the user for the tickets" do
        expect { request }.to change { user.payments.completed.count }.by(1)
      end

      it "tracks placed booking" do
        request

        expect(Analytics)
          .to have_received(:track)
          .with "booking-placed", user_id: user.id, concert_id: concert.id, paid: true
      end
    end

    context "with negative quantity" do
      let(:booking_params) do
        super().merge quantity: -1
      end

      include_examples "a bad request"
    end

    context "with quantity greater tickets limit" do
      let(:booking_params) do
        super().merge quantity: Booking::TICKET_LIMIT + 1
      end

      include_examples "a bad request"
    end

    context "with invalid ticket_type" do
      let(:booking_params) do
        super().merge ticket_type: "premium"
      end

      include_examples "a bad request"
    end

    context "when concert is sold out" do
      before do
        concert.update! remaining_ticket_count: 0
      end

      include_examples "a bad request"

      it "adds alert flash message" do
        request
        expect(flash[:alert]).to eq("Sorry, that concert is sold out!")
      end
    end

    context "when payment fails" do
      before do
        Payment.adapter = Payment::FailureAdapter.new
      end

      after do
        Payment.adapter = Payment::SuccessAdapter.new
      end

      include_examples "a placed booking"

      it "adds alert flash message" do
        request
        expect(flash[:alert]).to eq("Sorry, there was an error processing your payment!")
      end

      it "keeps pending payment for the tickets" do
        expect { request }.to change { user.payments.pending.count }.by(1)
      end

      it "tracks placed booking" do
        request

        expect(Analytics)
          .to have_received(:track)
          .with "booking-placed", user_id: user.id, concert_id: concert.id, paid: false
      end

      it "tracks failed payment" do
        request

        expect(Analytics)
          .to have_received(:track)
          .with "payment-failed", user_id: user.id, concert_id: concert.id
      end
    end
  end
end
