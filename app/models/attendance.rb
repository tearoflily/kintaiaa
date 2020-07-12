class Attendance < ApplicationRecord
  belongs_to :user
  attr_accessor :ok_flag


  validate :finished_at_is_invalid_without_a_started_at
  validate :started_at_than_finished_at_fast_if_invalid
  validate :after_finished_at_is_invalid_without_a_started_at
  validate :after_started_at_than_finished_at_fast_if_invalid
  
  
 
  
  def finished_at_is_invalid_without_a_started_at
    errors.add(:started_at, "が必要です") if started_at.blank? && finished_at.present?
  end
  
  def started_at_than_finished_at_fast_if_invalid
    if started_at.present? && finished_at.present?
      errors.add(:started_at, "より早い退勤時間は無効です") if started_at > finished_at && (tommorow == "0")
    end
  end
  
  def after_finished_at_is_invalid_without_a_started_at
    errors.add(:after_started_at, "が必要です") if after_started_at.blank? && after_finished_at.present?
  end

  def after_started_at_than_finished_at_fast_if_invalid
    if after_started_at.present? && after_finished_at.present?
    errors.add(:after_started_at, "より早い退勤時間は無効です") if after_started_at > after_finished_at && (tommorow_flag == "0")
    end
  end
  



  


  def self.search(search)

    if search
      where(worked_on: search.in_time_zone.all_month)
    else
      all
    end
  end

end
