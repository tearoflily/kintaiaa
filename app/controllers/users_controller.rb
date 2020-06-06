class UsersController < ApplicationController
  def index
    @users = User.all
  end
  
  def new
  end
  
  def create
  end
  
  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
    if @user.update_attributes(user_params)
      flash[:success] = "ユーザー情報を更新しました"
      redirect_to users_url
    else
      render :edit
    end
  end
  
  def destroy
    @user = User.find(params[:id])
    @user.destroy
    flash[:success] = "#{@user.name}削除が完了しました"
    redirect_to users_url
  end
  
  private
  
    def user_params
      params.require(:user).permit(:name, :email, :affiliation, :employee_number, :uid, :basic_work_time, 
                                    :designated_work_start_time, :designated_work_end_time, :password, :password_confirmation)
    end
  
  
end
