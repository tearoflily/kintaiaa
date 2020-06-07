class AttendancesController < ApplicationController
  before_action :set_one_month
  
  
  def new
   
  end
  
  def create
    @user = User.find(params[:user_id])
    @today = Date.current
    @attendance = @user.attendances.find_by(worked_on: params[:dayid])
    
    if @attendance.started_at.nil? 
      if @attendance.update_attribute(:started_at, Time.current)
        flash[:success] = "出勤登録しました"
        redirect_to new_user_attendance_path @user
      else
        flash[:danger] = "出勤登録失敗"
        render :new
      end
    elsif @attendance.finished_at.nil?
      if @attendance.update_attribute(:finished_at, Time.current)
        flash[:success] = "おつかれさまでした"
        redirect_to new_user_attendance_path @user
      else
        flash[:danger] = "退勤登録失敗"
        render :new
      end
    end
    
  end
  
  def edit
    @consent = User.where(superior: true)
    
  end
  
  def update
  end
  
  def destroy
  end
  
  
  
  
  
  
end
