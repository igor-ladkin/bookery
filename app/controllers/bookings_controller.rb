class BookingsController < ApplicationController
  include Dry::Monads[:result]

  before_action :check_unpaid_bookings, only: [:create, :new]
  before_action :set_concert

  def new
    @booking = Booking.new concert: @concert
  end

  def create
    case Bookings::PlaceOrderCase.new.call(buyer: current_user, concert: @concert, booking_params: booking_params)

    in Success({ booking: }) if booking.paid?
      flash.notice = "Your booking has been created!"
      redirect_to concerts_path

    in Success({ booking: })
      flash.alert = "Sorry, there was an error processing your payment!"
      redirect_to concerts_path

    in Failure({ code: :invalid_quantity, booking: })
      render_error :bad_request, booking

    in Failure({ code: :unsupported_ticket_type, booking: })
      render_error :unprocessable_entity, booking

    in Failure({ code: :payment_failed, booking: }) if booking.concert.reload.sold_out?
      flash.now[:alert] = "Sorry, that concert is sold out!"
      render_error :unprocessable_entity, booking

    in Failure({ code: :payment_failed, booking: })
      flash.now[:alert] = "Sorry, we only have #{booking.concert.remaining_ticket_count} #{"ticket".pluralize(booking.concert.remaining_ticket_count)} left for this concert!"
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
      .permit :ticket_type, :quantity
  end

  def render_error(status, booking)
    render :new, status: status, assigns: { booking: booking }
  end
end
