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

ActiveRecord::Schema.define(version: 20200628084256) do

  create_table "attendances", force: :cascade do |t|
    t.date "worked_on"
    t.datetime "started_at"
    t.datetime "finished_at"
    t.string "note"
    t.integer "user_id"
    t.string "work_change_now"
    t.string "work_change_log"
    t.integer "month_work"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "request_at"
    t.integer "request_type"
    t.integer "request_status"
    t.datetime "before_started_at"
    t.datetime "before_finished_at"
    t.datetime "after_started_at"
    t.datetime "after_finished_at"
    t.string "request_memo"
    t.string "who_consent"
    t.string "tommorow_flag", default: "0"
    t.integer "only_day", default: 1
    t.string "month_work_who_consent"
    t.index ["user_id"], name: "index_attendances_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.string "affiliation"
    t.integer "employee_number"
    t.string "uid"
    t.datetime "basic_work_time", default: "2020-06-24 23:00:00"
    t.datetime "designated_work_start_time", default: "2020-06-24 23:30:00"
    t.datetime "designated_work_end_time", default: "2020-06-25 08:30:00"
    t.boolean "superior", default: false
    t.boolean "admin", default: false
    t.string "password"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "password_digest"
    t.index ["email"], name: "index_users_on_email", unique: true
  end

end
