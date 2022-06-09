class CreatePayments < ActiveRecord::Migration[7.0]
  def change
    create_table :payments do |t|
      t.belongs_to :user, null: false, foreign_key: true, index: true
      t.belongs_to :booking, null: false, foreign_key: true, index: true
      t.string :state, null: false, index: true, default: "pending"

      t.timestamps
    end
  end
end
