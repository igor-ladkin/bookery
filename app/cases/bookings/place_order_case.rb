module Bookings
  class PlaceOrderCase
    include Dry::Transaction

    step :verify_params
    step :prepare_booking
    step :validate_booking
    step :reserve_tickets
    step :process_payment
    step :send_confirmation_email
    step :track_placed_order

    private

    def verify_params(params)
      Success params
    end

    def prepare_booking(buyer:, concert:, booking_params:)
      booking = buyer.bookings.new concert: concert, **booking_params
      Success booking: booking, buyer: buyer, concert: concert
    end

    def validate_booking(booking:, **params)
      if booking.valid?
        Success booking: booking, **params
      elsif booking.errors.has_key? :quantity
        Failure code: :invalid_quantity, booking: booking
      else
        Failure code: :unsupported_ticket_type, booking: booking
      end
    end

    def reserve_tickets(booking:, **params)
      Booking.transaction do
        booking.concert.decrement! :remaining_ticket_count, booking.quantity
        booking.save!
      end

      Success booking: booking, **params
    rescue ActiveRecord::StatementInvalid => e
      if e.message =~ /constraint failed: concert_remaining_ticket_count_positive/
        Failure code: :payment_failed, booking: booking
      else
        raise e
      end
    end

    def process_payment(booking:, buyer:, **params)
      Payment.process booking, buyer

      Success booking: booking, buyer: buyer, **params
    rescue Payment::ChargeError => e
      Analytics.track "payment-failed",
        concert_id: booking.concert_id,
        user_id: buyer.id

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
        paid: booking.paid?

      Success booking: booking, buyer: buyer, **params
    end
  end
end
