module SessionsHelper
  
  def log_in(user)
    session[:user_id] = user.id    
  end
  
  def log_out
    session.delete(:user_id)
    @current_user = nil
  end
  
  def current_user

    if (user_id = session[:user_id])
      @current_user ||= User.find_by(id: user_id)
    elsif (user_id = cookies.signed[:user_id])
      user = User.find_by(id: user_id)
      if user && user.authenticated?(cookies[:remeber_token])
        log_in user
        @current_user = user
      end
    end
  end
 
    
  def current_user?(user)
    
    user == current_user
  end
  
  def admin_user?(user)
    admin_check = User.find(user)
    admin_check.admin?
  end
  
  def superior_user?(user)
    superior_check = User.find(user)
    superior_check.superior?
  end
  
  def logged_in?
    !current_user.nil?
  end
  
  def now_view_correct_user?(user)
    user == params[:user_id].to_i
  end
  
end
