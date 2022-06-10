include ActionView::Helpers::AssetUrlHelper

Payment.delete_all
Booking.delete_all
Concert.delete_all
User.delete_all

alex, sasho, igor =
  User.create!([
    { name: "alex" },
    { name: "sasho" },
    { name: "igor" },
  ])

random_concert_params = -> do
  {
    starts_at: Faker::Time.between(from: 10.days.from_now, to: 6.months.from_now).beginning_of_hour,
    sales_open_at: Faker::Time.forward(days: 7).beginning_of_hour,
  }
end

imagine_dragons, kendrick_lamar, u2, adele, sam_smith, coldplay, khalid, foo_fighters, travis =
  Concert.create!([
    { title: "Imagine Dragons", image_url: image_url("imagine-dragons.jpeg"), remaining_ticket_count: 1000, available_ticket_types: ["standard", "vip"]     },
    { title: "Kendrick Lamar",  image_url: image_url("kendrick-lamar.jpeg"),  remaining_ticket_count: 1337, available_ticket_types: ["standard", "premium"] },
    { title: "U2",              image_url: image_url("u2.jpeg"),              remaining_ticket_count: 0,    available_ticket_types: ["premium", "vip"]      },
    { title: "Adele",           image_url: image_url("adele.jpeg"),           remaining_ticket_count: 298,                                                  },
    { title: "Sam Smith",       image_url: image_url("sam-smith.jpeg"),       remaining_ticket_count: 69,   available_ticket_types: ["standard"]            },
    { title: "Coldplay",        image_url: image_url("coldplay.jpeg"),        remaining_ticket_count: 420,  available_ticket_types: ["premium"]             },
    { title: "Khalid",          image_url: image_url("khalid.jpeg"),          remaining_ticket_count: 0,    available_ticket_types: ["premium"]             },
    { title: "Foo Fighters",    image_url: image_url("foo-fighters.jpeg"),    remaining_ticket_count: 3000,                                                 },
    { title: "Coldplay",        image_url: image_url("travis.jpeg"),          remaining_ticket_count: 10,   available_ticket_types: ["vip"]                 },
  ].map { _1.reverse_merge random_concert_params.call })

Booking
  .create!(user: sasho, concert: adele, ticket_type: "standard", quantity: 2)
  .then { |booking| Payment.create! booking: booking, user: sasho, state: :completed }
