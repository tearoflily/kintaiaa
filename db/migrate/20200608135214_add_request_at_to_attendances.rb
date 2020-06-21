class AddRequestAtToAttendances < ActiveRecord::Migration[5.1]
  def change
    add_column :attendances, :request_at, :datetime
    add_column :attendances, :request_type, :integer
    add_column :attendances, :request_status, :integer
    add_column :attendances, :before_started_at, :datetime
    add_column :attendances, :before_finished_at, :datetime
    add_column :attendances, :after_started_at, :datetime
    add_column :attendances, :after_finished_at, :datetime
    add_column :attendances, :request_memo, :string
    add_column :attendances, :who_consent, :string
    
  end
end
