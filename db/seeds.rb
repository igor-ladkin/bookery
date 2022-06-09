User.delete_all

User.create! name: "alex"
User.create! name: "sasho"
User.create! name: "igor"

Concert.delete_all

Concert.create! title: "Imagine Dragons", starts_at: 1.day.from_now, sales_open_at: "2022-07-10 13:00:00", remaining_ticket_count: 1000, available_ticket_types: ["standard", "vip"]
Concert.create! title: "Kendrick Lamar", starts_at: 1.day.from_now, sales_open_at: "2020-07-07 19:00:00", remaining_ticket_count: 500, available_ticket_types: ["standard", "premium"]
Concert.create! title: "Adele", starts_at: 1.day.from_now, sales_open_at: "2020-07-05 15:00:00", remaining_ticket_count: 300