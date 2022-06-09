# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.0].define(version: 2022_06_09_154251) do
  create_table "bookings", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "concert_id", null: false
    t.string "state", default: "pending", null: false
    t.integer "quantity", default: 0, null: false
    t.string "ticket_type", default: "standard", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["concert_id"], name: "index_bookings_on_concert_id"
    t.index ["user_id"], name: "index_bookings_on_user_id"
  end

  create_table "concerts", force: :cascade do |t|
    t.string "title", null: false
    t.datetime "starts_at", null: false
    t.datetime "sales_open_at", null: false
    t.integer "remaining_ticket_count", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "available_ticket_types", default: "---\n- standard\n"
    t.check_constraint "remaining_ticket_count >= 0", name: "concert_remaining_ticket_count_positive"
  end

  create_table "users", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_users_on_name"
  end

  add_foreign_key "bookings", "concerts"
  add_foreign_key "bookings", "users"
end
