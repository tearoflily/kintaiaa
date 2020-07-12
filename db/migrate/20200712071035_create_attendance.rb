class CreateAttendance < ActiveRecord::Migration[5.1]
  def change
    create_table :attendances do |t|
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
          t.string "tommorow", default: "0"
          t.index ["user_id"], name: "index_attendances_on_user_id"
    end
  end
end
