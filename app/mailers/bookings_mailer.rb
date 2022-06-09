class BookingsMailer < ApplicationMailer
  def confirmation_email
    @booking = params[:booking]
    mail to: "to@example.org"
  end
end
