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

ActiveRecord::Schema.define(version: 20160416180254) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "downloads", force: :cascade do |t|
    t.inet     "ip"
    t.string   "filename"
    t.integer  "size"
    t.integer  "referer_id"
    t.integer  "user_agent_id"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  add_index "downloads", ["filename"], name: "index_downloads_on_filename", using: :btree
  add_index "downloads", ["ip"], name: "index_downloads_on_ip", using: :btree
  add_index "downloads", ["referer_id"], name: "index_downloads_on_referer_id", using: :btree
  add_index "downloads", ["user_agent_id"], name: "index_downloads_on_user_agent_id", using: :btree

  create_table "referers", force: :cascade do |t|
    t.text     "referer_string"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
  end

  add_index "referers", ["referer_string"], name: "index_referers_on_referer_string", unique: true, using: :btree

  create_table "uploads", force: :cascade do |t|
    t.inet     "ip"
    t.string   "filename"
    t.integer  "size"
    t.integer  "user_agent_id"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  add_index "uploads", ["created_at"], name: "index_uploads_on_created_at", using: :btree
  add_index "uploads", ["filename"], name: "index_uploads_on_filename", using: :btree
  add_index "uploads", ["ip"], name: "index_uploads_on_ip", using: :btree
  add_index "uploads", ["user_agent_id"], name: "index_uploads_on_user_agent_id", using: :btree

  create_table "user_agents", force: :cascade do |t|
    t.text     "user_agent_string"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
  end

  add_index "user_agents", ["user_agent_string"], name: "index_user_agents_on_user_agent_string", unique: true, using: :btree

end
