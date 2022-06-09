class AddAvailableTicketTypeToConcerts < ActiveRecord::Migration[7.0]
  def change
    add_column :concerts, :available_ticket_types, :text, default: ["standard"].to_yaml
  end
end
