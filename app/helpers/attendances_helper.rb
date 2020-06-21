module AttendancesHelper
  
  def who_name(user_id)
    @user = User.find(user_id)
    return @user.name
  end
  

end
