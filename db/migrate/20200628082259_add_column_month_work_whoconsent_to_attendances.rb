class AddColumnMonthWorkWhoconsentToAttendances < ActiveRecord::Migration[5.1]
  def up
    add_column :attendances, :month_work_who_consent, :string
  end
  
  def down
  end
end
