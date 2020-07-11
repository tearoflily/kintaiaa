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
  
  
  def zishazikan(start_time, finish_time, tommorow)
    start = (start_time.hour * 60) + start_time.min
    s_finish = (finish_time.hour * 60) + finish_time.min
    
    if tommorow == "1"
      finish = s_finish + 720 
    elsif tommorow == "0" || tommorow == nil
      finish = s_finish + 0
    end
    
    sum_min = finish.to_i - start.to_i
    sum_hour = sum_min / 60.00
    sum_string = sum_hour.round(3).to_s
    sum_array = sum_string.split(".")
    sum_min_min = sum_array[1].to_i * 0.06
    @sum_time = sum_array[0] + ":" + format("%02d",sum_min_min)

    return @sum_time

  end
  
  def zaisha(finish, start)
    finish = finish
    start = start
    format("%.2f", (((finish - start) / 60) / 60))
  end
  
  def view_sum(time)

    time_f = time.to_s
    sum_array = time_f.split(".")
    sum_min_min = sum_array[1].to_i / 166.6 * 100
    @sum_time = sum_array[0] + ":" + format("%02d",sum_min_min)

    return @sum_time
  end
 
end
