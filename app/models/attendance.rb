class Attendance < ApplicationRecord
  belongs_to :user
  attr_accessor :ok_flag

  def self.search(search)

    if search
      where(worked_on: search.in_time_zone.all_month)
    else
      all
    end
  end

end
