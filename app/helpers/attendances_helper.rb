module AttendancesHelper
  
  def who_name(user_id)

    @user = User.find(user_id)
    return @user.name
  end
  
  def who_request_status(request_status, request_type)
    @status = '*勤怠変更 申請中*' if request_status == 0 && request_type == 1
    @status = '【勤怠変更 承認済み】' if request_status == 1 && request_type == 1
    @status = '【勤怠変更 承認拒否】' if request_status == 2 && request_type == 1
    
    @status = '*残業 申請中*' if request_status == 0 && request_type == 2
    @status = '【残業変更 承認済み】' if request_status == 1 && request_type == 2
    @status = '【残業変更 承認拒否】' if request_status == 2 && request_type == 2
    return @status
  end
  
  def over24(hour)
    
    hour = hour.to_i
    hour += 24
    return hour
  end
  
  def over24_time_type(time)
  
    hour = time.hour
    min = time.min
    
    hour_i = hour.to_i
    hour_i += 24
    hour_s = hour_i.to_s
    min_s = min.to_s
    
    hour_0 = hour_s.rjust(2, '0')
    min_0 = min_s.rjust(2, '0')
    time = hour_0 + "：" + min_0
    
    return time
  end
  
  
  def month_confirm_count(id)
 
    count_attendance = Attendance.where(month_work_who_consent: id).where(month_work: 0)
    uniq_user = count_attendance.pluck(:user_id).uniq.count
    return uniq_user
  end
  
  def edit_confirm_count(id)
    count = Attendance.where(who_consent: id).where(request_status: 0).where(request_type: 1).count
    return count
  end
  
  def overwork_confirm_count(id)
    count = Attendance.where(who_consent: id).where(request_status: 0).where(request_type: 2).count
    return count
  end

end
