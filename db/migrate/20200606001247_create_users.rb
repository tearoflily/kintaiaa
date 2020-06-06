class CreateUsers < ActiveRecord::Migration[5.1]
  def change
    create_table :users do |t|
      t.string :name
      t.string :email
      t.string :affiliation
      t.integer :employee_number
      t.string :uid
      t.time :basic_work_time
      t.time :designated_work_start_time
      t.time :designated_work_end_time
      t.boolean :superior
      t.boolean :admin
      t.string :password

      t.timestamps
    end
  end
end
