class BookingsController < ApplicationController
  include Dry::Monads[:result]

  before_action :check_unpaid_bookings, only: [:create, :new]
  before_action :set_concert

  def new
    @booking = Booking.new concert: @concert
  end

  def create
    case Bookings.place_booking(buyer: current_user, concert: @concert, booking_params: booking_params)
    in Success(booking:) if booking.paid?
      redirect_to concerts_path, notice: "Your booking has been created!"

    in Success(booking:)
      redirect_to concerts_path, alert: "Sorry, there was an error processing your payment!"

    in Failure(error_code: :invalid_quantity, booking:)
      render_error :bad_request, booking

    in Failure(error_code: :invalid_ticket_type, booking:)
      render_error :unprocessable_entity, booking

    in Failure(error_code: :ticket_reservation_failed, booking:) if booking.concert.sold_out?
      flash[:alert] = "Sorry, that concert is sold out!"
      render_error :unprocessable_entity, booking

    in Failure(error_code: :ticket_reservation_failed, booking:)
      flash[:alert] =  "Sorry, we only have #{booking.concert.remaining_ticket_count} #{"ticket".pluralize(booking.concert.remaining_ticket_count)} left for this concert!"
      render_error :unprocessable_entity, booking

    in Failure(_)
      raise "Something went completely wrong!"
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

  def requested_quantity
    booking_params[:quantity].to_i
  end

  def render_error(status, booking)
    render :new, status: status, assigns: { booking: booking }
  end
end
