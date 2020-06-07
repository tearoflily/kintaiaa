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
      else
        flash[:danger] = "出勤登録失敗"
      end
    elsif @attendance.finished_at.nil?
      if @attendance.update_attribute(:finished_at, Time.current)
        flash[:success] = "おつかれさまでした"
        redirect_to user_attendance_pathattendance
      else
        flash[:danger] = "退勤登録失敗"
      end
    end
    
  end
  
  def edit
  end
  
  def update
  end
  
  def destroy
  end
  
  
  
  
  
  
end
