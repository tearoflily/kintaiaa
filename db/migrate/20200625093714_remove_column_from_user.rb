class RemoveColumnFromUser < ActiveRecord::Migration[5.1]
  def up
    remove_column :users, :only_day
  end

  def down
    add_column :users, :only_day, :integer
  end
end
