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

ActiveRecord::Schema.define(version: 20180402051330) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "join_dbs", force: :cascade do |t|
    t.string   "name"
    t.string   "host"
    t.integer  "port"
    t.integer  "user_id"
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
    t.string   "username"
    t.string   "task_arn"
    t.integer  "status",     default: 1
    t.index ["user_id"], name: "index_join_dbs_on_user_id", using: :btree
  end

  create_table "mappings", force: :cascade do |t|
    t.string   "name"
    t.integer  "join_db_id"
    t.integer  "user_id"
    t.integer  "remote_db_one"
    t.integer  "remote_db_two"
    t.string   "table_one"
    t.string   "table_two"
    t.string   "column_one"
    t.string   "column_two"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  create_table "notifications", force: :cascade do |t|
    t.string   "message"
    t.integer  "notification_type"
    t.integer  "user_id"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
    t.integer  "status"
    t.index ["user_id"], name: "index_notifications_on_user_id", using: :btree
  end

  create_table "remote_dbs", force: :cascade do |t|
    t.string   "name"
    t.string   "schema"
    t.string   "host"
    t.integer  "port"
    t.string   "remote_user"
    t.integer  "db_type"
    t.integer  "join_db_id"
    t.string   "database_name"
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
    t.string   "filepath"
    t.string   "table_name"
    t.integer  "status",        default: 1
    t.index ["join_db_id"], name: "index_remote_dbs_on_join_db_id", using: :btree
  end

  create_table "users", force: :cascade do |t|
    t.string   "name"
    t.string   "email"
    t.string   "password_digest"
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
    t.boolean  "email_confirmed", default: false
    t.string   "confirm_token"
    t.integer  "tier",            default: 0
    t.integer  "status"
    t.string   "reset_token"
  end

end
