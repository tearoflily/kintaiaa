class CreateAttendances < ActiveRecord::Migration[5.1]
  def change
    create_table :attendances do |t|
      t.date :worked_on
      t.datetime :started_at
      t.datetime :finished_at
      t.string :note
      t.references :user, foreign_key: true
      t.string :work_change_now
      t.string :work_change_log
      t.boolean :month_work

      t.timestamps
    end
  end
end
