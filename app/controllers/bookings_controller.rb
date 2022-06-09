class BookingsController < ApplicationController
  before_action :set_concert

  def new
    @booking = Booking.new concert: @concert
  end

  def create
    @booking = current_user.bookings.new booking_params

    if @booking.save
      redirect_to concerts_path, notice: "Your booking has been created!"
    else
      render :new, status: :unprocessable_entity
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
