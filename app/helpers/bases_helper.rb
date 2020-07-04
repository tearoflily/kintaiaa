module BasesHelper
  
  
  def base_type(type)
    if type == "0"
      return 'タイプA'
    elsif type == "1"
      return 'タイプB'
    elsif type == "2"
      return 'タイプC'
    end
  end
  
end
