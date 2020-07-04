class AddTommorowToAttendances < ActiveRecord::Migration[5.1]
  def change
    add_column :attendances, :tommorow, :string, default: '0'
  end
  

end
