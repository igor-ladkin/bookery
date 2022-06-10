include ActionView::Helpers::AssetUrlHelper

Payment.delete_all
Booking.delete_all
Concert.delete_all
User.delete_all

alex  = User.create! name: "alex"
sasho = User.create! name: "sasho"
igor  = User.create! name: "igor"

imagine_dragons = Concert.create! title: "Imagine Dragons", starts_at: 1.day.from_now, sales_open_at: "2022-07-10 13:00:00", remaining_ticket_count: 1000, available_ticket_types: ["standard", "vip"], image_url: image_url("imagine-dragons.jpeg")
kendrick_lamar  = Concert.create! title: "Kendrick Lamar", starts_at: 1.day.from_now, sales_open_at: "2020-07-07 19:00:00", remaining_ticket_count: 1337, available_ticket_types: ["standard", "premium"], image_url: image_url("kendrick-lamar.jpeg")
adele           = Concert.create! title: "Adele", starts_at: 1.day.from_now, sales_open_at: "2020-07-05 15:00:00", remaining_ticket_count: 298, image_url: image_url("adele.jpeg")
u2              = Concert.create! title: "U2", starts_at: 1.day.from_now, sales_open_at: "2020-07-05 15:00:00", remaining_ticket_count: 500, available_ticket_types: ["premium", "vip"], image_url: image_url("u2.jpeg")
foo_fighters    = Concert.create! title: "Foo Fighters", starts_at: 1.day.from_now, sales_open_at: "2020-07-05 15:00:00", remaining_ticket_count: 3000, image_url: image_url("foo-fighters.jpeg")
coldplay        = Concert.create! title: "Coldplay", starts_at: 1.day.from_now, sales_open_at: "2020-07-05 15:00:00", remaining_ticket_count: 420, available_ticket_types: ["premium"], image_url: image_url("coldplay.jpeg")

booking = Booking.create! user: sasho, concert: adele, ticket_type: "standard", quantity: 2

Payment.create! booking: booking, user: sasho, state: :completed
