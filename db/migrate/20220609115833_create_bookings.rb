class CreateBookings < ActiveRecord::Migration[7.0]
  def change
    create_table :bookings do |t|
      t.belongs_to :user, null: false, foreign_key: true, index: true
      t.belongs_to :concert, null: false, foreign_key: true, index: true
      t.string :state, null: false, default: "pending"
      t.integer :quantity, null: false, default: 0
      t.string :ticket_type, null: false, default: "standard"

      t.timestamps
    end
  end
end
