class BookingPolicy < ApplicationPolicy
  class Scope < Scope
  end

  def create?
    user.bookings.all?(&:paid?)
  end

  def new?
    create?
  end
end
