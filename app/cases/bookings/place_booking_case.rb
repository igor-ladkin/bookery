module Bookings
  class PlaceBookingCase
    include Dry::Transaction

    step :prepare_booking
    step :reserve_tickets
    step :process_payment
    step :send_confirmation_email
    step :track_booking_placed

    private

    def prepare_booking(buyer:, concert:, booking_params:)
      booking = buyer.bookings.new concert: concert, **booking_params
      Success booking: booking, concert: concert, buyer: buyer
    end

    def reserve_tickets(booking:, **rest)
      Booking.transaction do
        booking.concert.decrement! :remaining_ticket_count, booking.quantity
        booking.save!
      end

      Success booking: booking, **rest
    end

    def process_payment(booking:, buyer:, **rest)
      Payment.process(booking, buyer)

      Success booking: booking, buyer: buyer, **rest
    end

    def send_confirmation_email(booking:, **rest)
      BookingsMailer
        .with(booking: booking)
        .confirmation_email
        .deliver_later

      Success booking: booking, **rest
    end

    def track_booking_placed(booking:, buyer:, **rest)
      Analytics.track "booking-placed",
        concert_id: booking.concert_id,
        user_id: buyer.id,
        paid: true

      Success booking: booking, buyer: buyer, **rest
    end
  end
end