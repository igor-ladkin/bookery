module Bookings
  class PlaceOrderCase
    include Dry::Transaction

    step :verify_params
    step :prepare_booking
    step :reserve_tickets
    step :process_payment
    step :send_confirmation_email
    step :track_placed_order

    private

    def verify_params(params)
      Success params
    end

    def prepare_booking(params)
      booking = params[:buyer].bookings.new params[:booking_params]
      Success booking: booking, **params
    end

    def reserve_tickets(booking:, **params)
      Booking.transaction do
        booking.concert.decrement! :remaining_ticket_count, booking.quantity
        booking.save!
      end

      Success booking: booking, **params
    end

    def process_payment(booking:, buyer:, **params)
      Payment.process booking, buyer

      Success booking: booking, buyer: buyer, **params
    end

    def send_confirmation_email(booking:, **params)
      BookingsMailer
        .with(booking: booking)
        .confirmation_email
        .deliver_later

      Success booking: booking, **params
    end

    def track_placed_order(booking:, buyer:, **params)
      Analytics.track "booking-placed",
        concert_id: booking.concert_id,
        user_id: buyer.id,
        paid: true

      Success booking: booking, buyer: buyer, **params
    end
  end
end
