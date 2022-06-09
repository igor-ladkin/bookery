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

    context "happy path" do
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
    end

    context "with invalid quantity" do
      let(:booking_params) do
        super().merge quantity: -1
      end

      include_examples "a bad request"
    end

    context "with invalid ticket_type" do
      let(:booking_params) do
        super().merge ticket_type: "premium"
      end

      include_examples "a bad request"
    end
  end
end
