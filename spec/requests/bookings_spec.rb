require 'rails_helper'

RSpec.describe "Bookings", type: :request do
  describe "POST /create" do
    shared_examples "bad request" do
      it "returns http bad request" do
        request
        expect(response).to have_http_status(:bad_request)
      end
    end

    shared_examples "unprocessable entity" do
      it "returns http unprocessable entity" do
        request
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    shared_examples "booking not placed" do
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

    shared_examples "booking placed" do
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
      include_examples "booking placed"

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

    context "with quantity as a random string" do
      let(:booking_params) do
        super().merge quantity: "random"
      end

      include_examples "bad request"
      include_examples "booking not placed"

      it "adds field error" do
        request
        expect(response.body).to match(/is not a number/)
      end
    end

    context "with non-positive quantity" do
      let(:booking_params) do
        super().merge quantity: -1
      end

      include_examples "bad request"
      include_examples "booking not placed"

      it "adds field error" do
        request
        expect(response.body).to match(/must be greater than or equal to 1/)
      end
    end

    context "with quantity greater than tickets limit" do
      let(:booking_params) do
        super().merge quantity: Booking::TICKET_LIMIT + 1
      end

      include_examples "bad request"
      include_examples "booking not placed"

      it "adds field error" do
        request
        expect(response.body).to match(/must be less than or equal to #{Booking::TICKET_LIMIT}/)
      end
    end

    context "with quantity greater than remaining tickets" do
      let(:booking_params) do
        super().merge quantity: 3
      end

      before do
        concert.update! remaining_ticket_count: 2
      end

      include_examples "unprocessable entity"
      include_examples "booking not placed"

      it "adds alert flash message" do
        request
        expect(flash[:alert]).to eq("Sorry, we only have 2 tickets left for this concert!")
      end
    end

    context "with invalid ticket_type" do
      let(:booking_params) do
        super().merge ticket_type: "premium"
      end

      include_examples "unprocessable entity"
      include_examples "booking not placed"
    end

    context "when concert is sold out" do
      before do
        concert.update! remaining_ticket_count: 0
      end

      include_examples "unprocessable entity"
      include_examples "booking not placed"

      it "adds alert flash message" do
        request
        expect(flash[:alert]).to eq("Sorry, that concert is sold out!")
      end
    end

    context "when user has unpaid bookings" do
      before do
        user.bookings.create booking_params
      end

      it "returns http redirect" do
        request
        expect(response).to have_http_status(:redirect)
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

      it "adds alert flash message" do
        request
        expect(flash[:alert]).to eq("Sorry, you have unpaid bookings!")
      end
    end

    context "when payment fails" do
      before do
        Payment.adapter = Payment::FailureAdapter.new
      end

      after do
        Payment.adapter = Payment::SuccessAdapter.new
      end

      include_examples "booking placed"

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
