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

ActiveRecord::Schema.define(version: 20160509171748) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer  "priority",   default: 0, null: false
    t.integer  "attempts",   default: 0, null: false
    t.text     "handler",                null: false
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], name: "delayed_jobs_priority", using: :btree

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

  create_table "dumped_files", force: :cascade do |t|
    t.datetime "accessed_at"
    t.boolean  "file_frozen", default: false
    t.string   "filename"
    t.integer  "size"
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
  end

  add_index "dumped_files", ["accessed_at"], name: "index_dumped_files_on_accessed_at", using: :btree
  add_index "dumped_files", ["filename"], name: "index_dumped_files_on_filename", unique: true, using: :btree
  add_index "dumped_files", ["size"], name: "index_dumped_files_on_size", using: :btree

  create_table "file_freezes", force: :cascade do |t|
    t.string   "filename"
    t.integer  "size"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "file_freezes", ["filename"], name: "index_file_freezes_on_filename", using: :btree
  add_index "file_freezes", ["size"], name: "index_file_freezes_on_size", using: :btree

  create_table "frozen_files", force: :cascade do |t|
    t.string   "file_id"
    t.integer  "dumped_file_id"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
  end

  add_index "frozen_files", ["dumped_file_id"], name: "index_frozen_files_on_dumped_file_id", unique: true, using: :btree

  create_table "referers", force: :cascade do |t|
    t.text     "referer_string"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
  end

  add_index "referers", ["referer_string"], name: "index_referers_on_referer_string", using: :hash
  add_index "referers", ["referer_string"], name: "referer_string_constraint", unique: true, using: :btree

  create_table "simple_captcha_data", force: :cascade do |t|
    t.string   "key",        limit: 40
    t.string   "value",      limit: 6
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "simple_captcha_data", ["key"], name: "idx_key", using: :btree

  create_table "thaw_requests", force: :cascade do |t|
    t.string   "filename"
    t.integer  "size"
    t.integer  "referer_id"
    t.integer  "user_agent_id"
    t.inet     "ip"
    t.boolean  "finished",      default: false
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
  end

  add_index "thaw_requests", ["filename"], name: "index_thaw_requests_on_filename", using: :btree
  add_index "thaw_requests", ["ip"], name: "index_thaw_requests_on_ip", using: :btree
  add_index "thaw_requests", ["referer_id"], name: "index_thaw_requests_on_referer_id", using: :btree
  add_index "thaw_requests", ["size"], name: "index_thaw_requests_on_size", using: :btree
  add_index "thaw_requests", ["user_agent_id"], name: "index_thaw_requests_on_user_agent_id", using: :btree

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

  add_index "user_agents", ["user_agent_string"], name: "index_user_agents_on_user_agent_string", using: :hash
  add_index "user_agents", ["user_agent_string"], name: "user_agent_string_constraint", unique: true, using: :btree

end
