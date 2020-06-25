class AddColumnOnedayToAttendances < ActiveRecord::Migration[5.1]
  def up
    add_column :users, :only_day, :integer
  end
  
  def down
  end
end
