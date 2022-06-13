module Bookings
  class PlaceBookingCase
    include Dry::Transaction

    step :prepare_booking
    step :validate_booking
    step :reserve_tickets
    step :process_payment
    tee :send_confirmation_email
    tee :track_booking_placed

    private

    def prepare_booking(buyer:, concert:, booking_params:)
      booking = buyer.bookings.new concert: concert, **booking_params
      Success booking: booking, concert: concert, buyer: buyer
    end

    def validate_booking(booking:, **rest)
      if booking.valid?
        Success booking: booking, **rest
      elsif booking.errors.has_key? :quantity
        Failure error_code: :invalid_quantity, booking: booking
      else
        Failure error_code: :invalid_ticket_type, booking: booking
      end
    end

    def reserve_tickets(booking:, **rest)
      Booking.transaction do
        booking.concert.decrement! :remaining_ticket_count, booking.quantity
        booking.save!
      end

      Success booking: booking, **rest
    rescue ActiveRecord::StatementInvalid => e
      if e.message =~ /constraint failed: concert_remaining_ticket_count_positive/
        booking.concert.reload
        Failure error_code: :ticket_reservation_failed, booking: booking, **rest
      else
        raise e
      end
    end

    def process_payment(booking:, buyer:, **rest)
      Payment.process(booking, buyer)

      Success booking: booking, buyer: buyer, **rest
    rescue Payment::ChargeError => e
      Analytics.track "payment-failed",
        concert_id: booking.concert_id,
        user_id: buyer.id

      Success booking: booking, buyer: buyer, **rest
    end

    def send_confirmation_email(booking:, **rest)
      BookingsMailer
        .with(booking: booking)
        .confirmation_email
        .deliver_later
    end

    def track_booking_placed(booking:, buyer:, **rest)
      Analytics.track "booking-placed",
        concert_id: booking.concert_id,
        user_id: buyer.id,
        paid: booking.paid?
    end
  end
end
