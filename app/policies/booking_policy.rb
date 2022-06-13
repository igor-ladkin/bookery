class BookingPolicy < ApplicationPolicy
  def create?
    user.bookings.all?(&:paid?)
  end

  def new?
    create?
  end
end
