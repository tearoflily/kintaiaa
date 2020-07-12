class CreateUser < ActiveRecord::Migration[5.1]
  def change
    create_table :users do |t|
      t.string "name"
      t.string "email"
      t.string "affiliation"
      t.integer "employee_number"
      t.string "uid"
      t.datetime "basic_work_time", default: "2020-07-08 23:00:00"
      t.datetime "designated_work_start_time", default: "2020-07-08 23:30:00"
      t.datetime "designated_work_end_time", default: "2020-07-09 08:30:00"
      t.boolean "superior", default: false
      t.boolean "admin", default: false
      t.string "password"
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.string "password_digest"
      t.index ["email"], name: "index_users_on_email", unique: true
    end
  end
end
