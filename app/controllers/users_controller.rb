class UsersController < ApplicationController
  before_action :logged_in_user, only: [:index, :edit, :update, :import, :destroy]
  before_action :admin_user, only: [:index, :edit, :update, :import]
  
  
  
  def index
    @users = User.all
  end
  
  def show
  end
  
  def new
    @user = User.new
  end
  
  def create
    
    @user = User.new(user_params)
    if @user.save
      flash[:success] = '新規作成に成功しました。'
      log_in @user
      redirect_to new_user_attendance_path @user
    else
      flash[:danger] = "ユーザー登録に失敗しました。"
      render :new
    end
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
    
        
    def superior_user
      unless current_user.superior || current_user.admin
        flash[:danger] = "管理者または上長のみ操作可能です。"
        redirect_to root_url
      end
    end
    
    def admin_user
      unless current_user.admin
        flash[:danger] = "管理者のみ操作可能です。"
        redirect_to root_url
      end
    end
    
    def admin_or_correct_user
      @user = User.find(params[:user_id]) if @user.blank?
      unless current_user?(@user) || current_user.admin?
        flash[:danger] = "編集権限がありません。"
        redirect_to root_url
      end
    end
    

    
    
    def correct_user
      redirect_to(root_url) unless current_user?(@user)
    end
    

  
  
  
end
