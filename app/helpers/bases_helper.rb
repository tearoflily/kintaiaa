module BasesHelper
  
  
  def base_type(type)
    if type == "0"
      return '出勤'
    elsif type == "1"
      return '退勤'
    end
  end
  
end
