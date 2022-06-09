class AddCheckConstraintToConcerts < ActiveRecord::Migration[7.0]
  def change
    add_check_constraint :concerts, "remaining_ticket_count >= 0", name: "concert_remaining_ticket_count_positive"
  end
end
