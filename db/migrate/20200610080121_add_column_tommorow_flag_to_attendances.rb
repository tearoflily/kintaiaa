class AddColumnTommorowFlagToAttendances < ActiveRecord::Migration[5.1]
  def change
    add_column :attendances, :tommorow_flag, :string, default: '0'
  end
end
