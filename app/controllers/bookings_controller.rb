class BookingsController < ApplicationController
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

    redirect_to concerts_path, notice: "Your booking has been created!"
  rescue ActiveRecord::RecordInvalid
    render :new, status: :unprocessable_entity

  rescue ActiveRecord::StatementInvalid => e
    if e.message =~ /constraint failed: concert_remaining_ticket_count_positive/
      flash.now[:alert] = "Sorry, that concert is sold out!"
      render :new, status: :unprocessable_entity
    else
      raise e
    end
  end

  private

  def set_concert
    @concert = Concert.find params[:concert_id]
  end

  def booking_params
    params
      .require(:booking)
      .permit :concert_id, :ticket_type, :quantity
  end
end
