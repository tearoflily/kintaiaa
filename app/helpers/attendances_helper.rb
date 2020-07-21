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
    hour = finish_time.hour - start_time.hour
    min = finish_time.min - start_time.min
    hour = ( hour + 24 ) if tommorow == "1"
    
    if min < 0
      min = min + 60
      hour = hour - 1
    end

    @sum_time = hour.to_s + ":" + format("%02d",min).to_s
  
    return @sum_time

  end
  
  def zaisha(start_time, finish_time, tommorow)
    hour = finish_time.hour - start_time.hour
    min = finish_time.min - start_time.min
    hour = ( hour + 24 ) if tommorow == "1"
    
    if min < 0
      min = min + 60
      hour = hour - 1
    end
    @sum_time = {}
    @sum_time[:hour] = hour
    @sum_time[:min] = min
    
    return @sum_time
  end
  
  def view_sum(hour, min)

    time = hour * 60.0 + min
    sum_time = time / 60.00.to_f
    sum_zero = format("%.2f",sum_time)
    array_time = sum_zero.to_s.split(".")
    
   
    
    string_hour = array_time[0]
    time_min = array_time[1].to_i * 0.60
    time_min_round = time_min.round(0)

    
    @sum_time = string_hour.to_s + ":" + format("%02d",time_min_round).to_s
    
    return @sum_time
  end
  
  
  def zikangai(after_finished_at, user_id, tommorow)

    finished_at = Time.new(2020, 8, 1, after_finished_at.hour, after_finished_at.min, 0, "+09:00")


    if tommorow == "1"
      finished_at = finished_at + 24.hour
    end
    
    user = User.find(user_id)
    designated_work_end_time = Time.new(2020, 8, 1, user.designated_work_end_time.hour, user.designated_work_end_time.min, 0, "+09:00")
    
    
    time = finished_at - designated_work_end_time
    
    sa = Time.at(time).utc.strftime('%X')
   
    return sa.slice(0..4)
  end
 
end
