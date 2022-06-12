class BookingsController < ApplicationController
  before_action :check_unpaid_bookings, only: [:create, :new]
  before_action :set_concert

  def new
    @booking = Booking.new concert: @concert
  end

  def create
    Bookings::PlaceOrderCase.new.call(buyer: current_user, concert: @concert, booking_params: booking_params) do |result|
      result.success do |success|
        if success[:booking].paid?
          flash.notice = "Your booking has been created!"
        else
          flash.alert = "Sorry, there was an error processing your payment!"
        end

        redirect_to concerts_path
      end

      result.failure(:validate_booking) do |failure|
        if failure[:code] == :invalid_quantity
          render :new, status: :bad_request, assigns: { booking: failure[:booking] }
        else
          render :new, status: :unprocessable_entity, assigns: { booking: failure[:booking] }
        end
      end

      result.failure(:reserve_tickets) do |failure|
        flash.now[:alert] =
          if failure[:booking].concert.reload.sold_out?
            "Sorry, that concert is sold out!"
          else
            "Sorry, we only have #{failure[:booking].concert.remaining_ticket_count} #{"ticket".pluralize(failure[:booking].concert.remaining_ticket_count)} left for this concert!"
          end

        render :new, status: :unprocessable_entity, assigns: { booking: failure[:booking] }
      end

      result.failure do |failure|
        render :new, status: :unprocessable_entity
      end
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
