# encoding: UTF-8
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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20120127020200) do

  create_table "bids", :force => true do |t|
    t.integer  "user_id"
    t.integer  "entry_id"
    t.integer  "line_item_id"
    t.integer  "car_brand_id"
    t.decimal  "amount",       :precision => 10, :scale => 2
    t.integer  "quantity",                                    :default => 1,     :null => false
    t.decimal  "total",        :precision => 10, :scale => 2
    t.string   "bid_type"
    t.integer  "bid_speed"
    t.boolean  "lot",                                         :default => false
    t.string   "status",                                      :default => "New", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.date     "ordered"
    t.integer  "order_id"
    t.date     "delivered"
    t.date     "paid"
    t.date     "declined"
    t.date     "expired"
  end

  add_index "bids", ["entry_id"], :name => "index_bids_on_entry_id"
  add_index "bids", ["line_item_id"], :name => "index_bids_on_line_item_id"
  add_index "bids", ["order_id"], :name => "index_bids_on_order_id"
  add_index "bids", ["user_id"], :name => "index_bids_on_user_id"

  create_table "branches", :force => true do |t|
    t.integer  "company_id"
    t.string   "name"
    t.string   "address1"
    t.string   "address2"
    t.integer  "zip_code"
    t.integer  "city_id"
    t.integer  "approver_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "branches", ["approver_id"], :name => "index_branches_on_approver_id"
  add_index "branches", ["city_id"], :name => "index_branches_on_city_id"
  add_index "branches", ["company_id"], :name => "index_branches_on_company_id"

  create_table "car_brands", :force => true do |t|
    t.integer  "car_origin_id"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "car_brands", ["car_origin_id"], :name => "index_car_brands_on_car_origin_id"

  create_table "car_models", :force => true do |t|
    t.integer  "car_brand_id"
    t.string   "name"
    t.integer  "creator_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "car_models", ["car_brand_id"], :name => "index_car_models_on_car_brand_id"
  add_index "car_models", ["creator_id"], :name => "index_car_models_on_creator_id"

  create_table "car_origins", :force => true do |t|
    t.string "name"
  end

  create_table "car_parts", :force => true do |t|
    t.string   "name"
    t.string   "creator_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "car_variants", :force => true do |t|
    t.integer  "car_brand_id"
    t.integer  "car_model_id"
    t.string   "name"
    t.string   "start_year"
    t.string   "end_year"
    t.integer  "creator_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "car_variants", ["car_brand_id"], :name => "index_car_variants_on_car_brand_id"
  add_index "car_variants", ["car_model_id"], :name => "index_car_variants_on_car_model_id"
  add_index "car_variants", ["creator_id"], :name => "index_car_variants_on_creator_id"

  create_table "cities", :force => true do |t|
    t.string   "name"
    t.integer  "region_id"
    t.integer  "creator_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "companies", :force => true do |t|
    t.string   "name"
    t.string   "nickname"
    t.integer  "primary_role"
    t.date     "trial_start"
    t.date     "trial_end"
    t.date     "metering_date"
    t.decimal  "perf_ratio",    :precision => 5, :scale => 2
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "delayed_jobs", :force => true do |t|
    t.integer  "priority",   :default => 0
    t.integer  "attempts",   :default => 0
    t.text     "handler"
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], :name => "delayed_jobs_priority"

  create_table "entries", :force => true do |t|
    t.integer  "user_id"
    t.integer  "company_id"
    t.string   "ref_no"
    t.integer  "year_model"
    t.integer  "car_brand_id",      :default => 0
    t.integer  "car_model_id",      :default => 0
    t.integer  "car_variant_id",    :default => 0
    t.string   "plate_no"
    t.string   "serial_no"
    t.string   "motor_no"
    t.date     "date_of_loss"
    t.integer  "city_id"
    t.integer  "term_id"
    t.integer  "line_items_count",  :default => 0
    t.integer  "photos_count",      :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "status",            :default => "New"
    t.datetime "online"
    t.date     "bid_until"
    t.integer  "bids_count",        :default => 0
    t.datetime "decided"
    t.datetime "relisted"
    t.integer  "relist_count",      :default => 0
    t.date     "expired"
    t.boolean  "chargeable_expiry", :default => false
    t.integer  "oders_count",       :default => 0
  end

  add_index "entries", ["car_brand_id"], :name => "index_entries_on_car_brand_id"
  add_index "entries", ["car_model_id"], :name => "index_entries_on_car_model_id"
  add_index "entries", ["car_variant_id"], :name => "index_entries_on_car_variant_id"
  add_index "entries", ["city_id"], :name => "index_entries_on_city_id"
  add_index "entries", ["company_id"], :name => "index_entries_on_company_id"
  add_index "entries", ["term_id"], :name => "index_entries_on_term_id"
  add_index "entries", ["user_id"], :name => "index_entries_on_user_id"

  create_table "friendships", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "line_items", :force => true do |t|
    t.integer  "entry_id"
    t.integer  "car_part_id"
    t.string   "specs",       :default => ""
    t.integer  "quantity",    :default => 1
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "status",      :default => "New"
    t.integer  "bids_count",  :default => 0
    t.datetime "relisted"
    t.integer  "order_id"
  end

  add_index "line_items", ["car_part_id"], :name => "index_line_items_on_car_part_id"
  add_index "line_items", ["entry_id"], :name => "index_line_items_on_entry_id"

  create_table "orders", :force => true do |t|
    t.integer  "user_id"
    t.integer  "company_id"
    t.integer  "entry_id"
    t.string   "ref_no",                                             :default => ""
    t.string   "ref_name",                                           :default => ""
    t.string   "deliver_to",                                         :default => ""
    t.string   "address1",                                           :default => ""
    t.string   "address2",                                           :default => ""
    t.string   "contact_person",                                     :default => ""
    t.string   "phone",                                              :default => ""
    t.string   "fax",                                                :default => ""
    t.text     "instructions"
    t.string   "status",                                             :default => "New PO", :null => false
    t.string   "buyer_ip",                                           :default => ""
    t.integer  "items_count",                                        :default => 0,        :null => false
    t.decimal  "order_total",         :precision => 10, :scale => 2, :default => 0.0,      :null => false
    t.datetime "created_at"
    t.integer  "seller_id"
    t.boolean  "seller_confirmation",                                :default => false,    :null => false
    t.datetime "confirmed"
    t.date     "delivered"
    t.date     "due_date"
    t.date     "paid_temp"
    t.date     "paid"
    t.date     "cancelled"
    t.integer  "ratings_count",                                      :default => 0,        :null => false
  end

  add_index "orders", ["company_id"], :name => "index_orders_on_company_id"
  add_index "orders", ["entry_id"], :name => "index_orders_on_entry_id"
  add_index "orders", ["seller_id"], :name => "index_orders_on_seller_id"
  add_index "orders", ["user_id"], :name => "index_orders_on_user_id"

  create_table "photos", :force => true do |t|
    t.integer  "entry_id"
    t.string   "photo_file_name"
    t.string   "photo_content_type"
    t.integer  "photo_file_size"
    t.datetime "photo_updated_at"
    t.boolean  "processing",         :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "photos", ["entry_id"], :name => "index_photos_on_entry_id"

  create_table "profiles", :force => true do |t|
    t.integer  "user_id"
    t.integer  "company_id"
    t.integer  "branch_id"
    t.string   "first_name"
    t.string   "last_name"
    t.integer  "rank_id"
    t.string   "phone"
    t.string   "fax"
    t.date     "birthdate"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "profiles", ["branch_id"], :name => "index_profiles_on_branch_id"
  add_index "profiles", ["company_id"], :name => "index_profiles_on_company_id"
  add_index "profiles", ["user_id"], :name => "index_profiles_on_user_id"

  create_table "ranks", :force => true do |t|
    t.string "name"
  end

  create_table "regions", :force => true do |t|
    t.string "name"
  end

  create_table "roles", :force => true do |t|
    t.string "name"
  end

  create_table "roles_users", :id => false, :force => true do |t|
    t.integer "user_id"
    t.integer "role_id"
  end

  create_table "temp_companies", :force => true do |t|
    t.string   "name"
    t.string   "address1"
    t.string   "address2"
    t.string   "zip_code"
    t.integer  "city_id"
    t.string   "approver"
    t.string   "approver_position"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "primary_role"
    t.date     "trial_start"
    t.date     "trial_end"
    t.date     "metering_date"
    t.decimal  "perf_ratio",        :precision => 5, :scale => 2
  end

  create_table "terms", :force => true do |t|
    t.integer "name"
  end

  create_table "users", :force => true do |t|
    t.string   "username",               :limit => 20,                    :null => false
    t.string   "email",                                 :default => "",   :null => false
    t.string   "encrypted_password",     :limit => 128, :default => "",   :null => false
    t.string   "password_salt"
    t.string   "remember_token"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                         :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.integer  "failed_attempts",                       :default => 0
    t.string   "unlock_token"
    t.datetime "locked_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "enabled",                               :default => true, :null => false
    t.integer  "entries_count",                         :default => 0,    :null => false
    t.integer  "bids_count",                            :default => 0,    :null => false
    t.datetime "tos_agreed"
    t.boolean  "opt_in",                                :default => true, :null => false
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true
  add_index "users", ["unlock_token"], :name => "index_users_on_unlock_token", :unique => true
  add_index "users", ["username"], :name => "index_users_on_username"

end
