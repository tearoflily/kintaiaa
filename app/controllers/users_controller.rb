class UsersController < ApplicationController
  before_action :logged_in_user, only: [:index, :edit, :update, :import, :destroy]
  before_action :admin_user, only: [:index, :edit, :update, :import]
  
  
  
  def index
    @users = User.all
  end
  
  def show
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
    @user.password_confirmation = @user.password
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
  
  def import
    User.import(params[:file])
    redirect_to users_url
  end
  
  private
  
    def user_params
      params.require(:user).permit(:name, :email, :affiliation, :employee_number, :uid, :basic_work_time, 
                                    :designated_work_start_time, :designated_work_end_time, :password, :password_confirmation)
    end
    
  
  
end
