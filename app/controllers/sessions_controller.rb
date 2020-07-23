class SessionsController < ApplicationController
  def new
    @user = User.new
  end
  
  def create
    
    user = User.find_by(email: params[:session][:email].downcase)
 
    if user && user.authenticate(params[:session][:password])
      log_in(user)
      flash[:success] = "ログインしました。"
      redirect_to root_url
    else
      flash[:danger] = "ログインできませんでした"
      render :new
    end
  end
  
  def destroy
    log_out if logged_in?
    flash[:success] = "ログアウトが完了しました"
    redirect_to root_url
  end
  
  
  
  
end
