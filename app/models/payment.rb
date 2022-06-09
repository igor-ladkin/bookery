class Payment < ApplicationRecord
  Payment::ChargeError = Class.new StandardError

  class SuccessAdapter
    def process(booking, user)
      Payment.create! booking: booking, user: user, state: :completed
    end
  end

  class FailureAdapter
    def process(booking, user)
      Payment.create! booking: booking, user: user, state: :pending
      raise Payment::ChargeError
    end
  end

  cattr_accessor :adapter

  def self.process(...)
    adapter.process(...)
  end

  belongs_to :user
  belongs_to :booking

  enum state: {
    pending: "pending",
    completed: "completed",
    cancelled: "cancelled"
  }
end
