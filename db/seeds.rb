Payment.delete_all
Booking.delete_all
Concert.delete_all
User.delete_all


alex = User.create! name: "alex"
sasho = User.create! name: "sasho"
igor = User.create! name: "igor"

imagine_dragons = Concert.create! title: "Imagine Dragons", starts_at: 1.day.from_now, sales_open_at: "2022-07-10 13:00:00", remaining_ticket_count: 1000, available_ticket_types: ["standard", "vip"]
kendrick_lamar = Concert.create! title: "Kendrick Lamar", starts_at: 1.day.from_now, sales_open_at: "2020-07-07 19:00:00", remaining_ticket_count: 500, available_ticket_types: ["standard", "premium"]
adele = Concert.create! title: "Adele", starts_at: 1.day.from_now, sales_open_at: "2020-07-05 15:00:00", remaining_ticket_count: 298

booking = Booking.create! user: sasho, concert: adele, ticket_type: "standard", quantity: 2

Payment.create! booking: booking, user: sasho, state: :completed
