class ChangeDefaultMonthWorkToAttendances < ActiveRecord::Migration[5.1]
  def up
    change_column :attendances, :month_work, :integer
  end
  
  def down
    change_column :attendances, :month_work, :boolean
  end
end
