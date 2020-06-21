class Attendance < ApplicationRecord
  belongs_to :user
  attr_accessor :ok_flag

end
