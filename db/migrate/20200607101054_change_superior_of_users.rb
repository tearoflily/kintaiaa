class ChangeSuperiorOfUsers < ActiveRecord::Migration[5.1]
  def up
    change_column :users, :superior, :boolean, default: false
  end
  
  def down
    change_column :users, :superior, :boolean
  end

end
