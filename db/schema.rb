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
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20190917083500) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "address_types", force: :cascade do |t|
    t.string "description"
  end

  create_table "addresses", force: :cascade do |t|
    t.string  "address1"
    t.string  "address2"
    t.string  "city"
    t.string  "state",           limit: 2
    t.string  "zip"
    t.string  "home_phone"
    t.integer "contact1_id"
    t.integer "contact2_id"
    t.integer "address_type_id"
    t.string  "text"
  end

  create_table "addresses_groups", id: false, force: :cascade do |t|
    t.integer "address_id"
    t.integer "group_id"
  end

  create_table "contacts", force: :cascade do |t|
    t.string  "prefix"
    t.string  "first_name",  null: false
    t.string  "middle_name"
    t.string  "last_name",   null: false
    t.date    "birthday"
    t.string  "work_phone"
    t.string  "cell_phone"
    t.string  "email"
    t.string  "website"
    t.integer "address_id"
  end

  create_table "groups", force: :cascade do |t|
    t.string  "name"
    t.integer "user_id"
  end

  add_index "groups", ["user_id"], name: "index_groups_on_user_id", using: :btree

  create_table "sessions", force: :cascade do |t|
    t.string   "session_id"
    t.text     "data"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], name: "index_sessions_on_session_id", using: :btree

  create_table "settings", force: :cascade do |t|
    t.string   "key"
    t.string   "value"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", force: :cascade do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.jsonb    "settings"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

  add_foreign_key "addresses", "address_types", name: "fk_address_address_type"
  add_foreign_key "addresses", "contacts", column: "contact1_id", name: "fk_address_contact1"
  add_foreign_key "addresses", "contacts", column: "contact2_id", name: "fk_address_contact2"
  add_foreign_key "addresses_groups", "addresses", name: "fk_address"
  add_foreign_key "addresses_groups", "groups", name: "fk_groups"
  add_foreign_key "contacts", "addresses", name: "fk_contact_address"
  add_foreign_key "groups", "users"
end
