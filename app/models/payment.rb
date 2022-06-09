class Payment < ApplicationRecord
  belongs_to :user
  belongs_to :booking

  enum state: {
    pending: "pending",
    completed: "completed",
    cancelled: "cancelled"
  }
end
