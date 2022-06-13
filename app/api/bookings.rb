module Bookings
  extend self

  def place_booking(buyer:, concert:, booking_params:)
    Bookings::PlaceBookingCase.new.call buyer: buyer, concert: concert, booking_params: booking_params
  end
end
