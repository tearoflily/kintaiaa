class ChangeDataBasicWorkTimeToUsers < ActiveRecord::Migration[5.1]
  def change
    change_column :users, :basic_work_time, :datetime
    change_column :users, :designated_work_start_time, :datetime
    change_column :users, :designated_work_end_time, :datetime
  end
end
