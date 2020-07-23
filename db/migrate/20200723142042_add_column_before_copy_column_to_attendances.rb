class AddColumnBeforeCopyColumnToAttendances < ActiveRecord::Migration[5.1]
  def up
    add_column :attendances, :request_type_before_copy, :integer
    add_column :attendances, :request_status_before_copy, :integer
    add_column :attendances, :request_at_before_copy, :datetime
  end
  
  def down
  end
end
