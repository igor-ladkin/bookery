class RemoveStateFromBookings < ActiveRecord::Migration[7.0]
  def change
    remove_column :bookings, :state, :string, default: "pending", null: false
  end
end
