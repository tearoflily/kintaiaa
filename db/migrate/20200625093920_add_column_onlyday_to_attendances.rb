class AddColumnOnlydayToAttendances < ActiveRecord::Migration[5.1]
  def up
    add_column :attendances, :only_day, :integer, default: 1
  end
  
  def down
  end
end
