class AddColumnNoteTemporaryToAttendance < ActiveRecord::Migration[5.1]
  def up
    add_column :attendances, :note_temporary, :string
  end
  
  def down
  end
end
