class BookingsController < ApplicationController
  before_action :check_unpaid_bookings, only: [:create, :new]
  before_action :set_concert

  def new
    @booking = Booking.new concert: @concert
  end

  def create
    @booking = current_user.bookings.new booking_params

    Booking.transaction do
      @booking.concert.decrement! :remaining_ticket_count, @booking.quantity
      @booking.save!
    end

    payment = Payment.process(@booking, current_user)

    redirect_to concerts_path, notice: "Your booking has been created!"
  rescue ActiveRecord::RecordInvalid
    render :new, status: :unprocessable_entity

  rescue ActiveRecord::StatementInvalid => e
    if e.message =~ /constraint failed: concert_remaining_ticket_count_positive/
      flash.now[:alert] =
        if @concert.reload.sold_out?
          "Sorry, that concert is sold out!"
        else
          "Sorry, we only have #{@concert.remaining_ticket_count} #{"ticket".pluralize(@concert.remaining_ticket_count)} left for this concert!"
        end

      render :new, status: :unprocessable_entity
    else
      raise e
    end

  rescue Payment::ChargeError => e
    Analytics.track "payment-failed",
        concert_id: @booking.concert_id,
        user_id: current_user.id

    flash.now[:alert] = "Sorry, there was an error processing your payment!"
    redirect_to concerts_path

  ensure
    if @booking.persisted?
      BookingsMailer
        .with(booking: @booking)
        .confirmation_email
        .deliver_later

      Analytics.track "booking-placed",
        concert_id: @booking.concert_id,
        user_id: current_user.id,
        paid: @booking.paid?
    end
  end

  private

  def check_unpaid_bookings
    unless current_user.bookings.all?(&:paid?)
      redirect_to concerts_path, alert: "Sorry, you have unpaid bookings!"
    end
  end

  def set_concert
    @concert = Concert.find params[:concert_id]
  end

  def booking_params
    params
      .require(:booking)
      .permit :concert_id, :ticket_type, :quantity
  end
end
