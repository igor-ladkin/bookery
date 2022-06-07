class CreateConcerts < ActiveRecord::Migration[7.0]
  def change
    create_table :concerts do |t|
      t.string :title, null: false
      t.datetime :starts_at, null: false
      t.datetime :sales_open_at, null: false
      t.integer :remaining_ticket_count, null: false

      t.timestamps
    end
  end
end
