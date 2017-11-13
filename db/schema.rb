# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20171113204315) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "activities", force: :cascade do |t|
    t.string "title", null: false
    t.datetime "start_time", null: false
    t.datetime "end_time", null: false
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "price_list_id"
    t.index ["price_list_id"], name: "index_activities_on_price_list_id"
  end

  create_table "credit_mutations", force: :cascade do |t|
    t.string "description", null: false
    t.bigint "user_id", null: false
    t.bigint "activity_id"
    t.decimal "amount", precision: 8, scale: 2, null: false
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["activity_id"], name: "index_credit_mutations_on_activity_id"
    t.index ["user_id"], name: "index_credit_mutations_on_user_id"
  end

  create_table "order_rows", force: :cascade do |t|
    t.bigint "order_id", null: false
    t.bigint "product_id", null: false
    t.integer "product_count", null: false
    t.decimal "price_per_product", precision: 8, scale: 2, null: false
    t.index ["order_id"], name: "index_order_rows_on_order_id"
    t.index ["product_id"], name: "index_order_rows_on_product_id"
  end

  create_table "orders", force: :cascade do |t|
    t.decimal "order_total", precision: 8, scale: 2
    t.bigint "activity_id", null: false
    t.bigint "user_id", null: false
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["activity_id"], name: "index_orders_on_activity_id"
    t.index ["user_id"], name: "index_orders_on_user_id"
  end

  create_table "price_lists", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "product_prices", force: :cascade do |t|
    t.bigint "product_id"
    t.bigint "price_list_id"
    t.decimal "price", precision: 8, scale: 2
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["price_list_id"], name: "index_product_prices_on_price_list_id"
    t.index ["product_id", "price_list_id"], name: "index_product_prices_on_product_id_and_price_list_id", unique: true
    t.index ["product_id"], name: "index_product_prices_on_product_id"
  end

  create_table "products", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "requires_age", default: false, null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "provider"
    t.string "uid"
  end

end
