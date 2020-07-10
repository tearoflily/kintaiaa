require 'csv'
require 'nkf'
require 'date'
require 'time'

CSV.generate do |csv|
  csv_column_names = ["出勤日","出勤時間","退勤時間"]
  csv << csv_column_names
  @now_attendances  = @attendances.where(only_day: 1)

  @now_attendances.each do |attendance|
    atst = attendance.started_at.strftime("%H:%M") if attendance.started_at.present?
    if attendance.finished_at.present? && attendance.tommorow == "1"
      atfn = attendance.finished_at.strftime("%H:%M") 
      at = atfn.split(":")
      at_hour = at[0].to_i
      at_min = at[1].to_i
      at24 = at_hour + 24
      time = at24.to_s << ":" << at_min.to_s
    elsif attendance.finished_at.present? && attendance.tommorow == "0"
      time = attendance.finished_at.strftime("%H:%M") 
    else
    end
    
    csv_column_values = [
      attendance.worked_on,
      atst,
      time
    ]
    csv << csv_column_values
  end
end