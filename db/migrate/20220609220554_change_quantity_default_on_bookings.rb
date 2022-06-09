class ChangeQuantityDefaultOnBookings < ActiveRecord::Migration[7.0]
  def change
    change_column_default :bookings, :quantity, 1
  end
end
