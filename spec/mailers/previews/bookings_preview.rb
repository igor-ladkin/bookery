class BookingsPreview < ActionMailer::Preview
  def confirmation_email
    BookingsMailer.with(booking: Booking.take).confirmation_email
  end
end
