class AttendancesController < ApplicationController
  before_action :set_one_month



  def new
   @user = User.find(params[:user_id])
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

        render:new

        render :new

      end
    end
    
  end
  

  
  def edit
    @consent = User.where(superior: true)

    @attendance_update = Attendance.new
    @user = User.find(params[:user_id])

  end
  

 

  
  def update_waiting
    @user = User.find(params[:user_id])
    attendance_edit_params.each do |id, item|
      attendance = Attendance.find(id)
      if item["after_started_at(1i)"].present?
        item[:after_started_at] = DateTime.new(item["after_started_at(1i)"].to_i, item["after_started_at(2i)"].to_i, item["after_started_at(3i)"].to_i, item["after_started_at(4i)"].to_i, item["after_started_at(5i)"].to_i)
        item[:after_finished_at] = DateTime.new(item["after_finished_at(1i)"].to_i, item["after_finished_at(2i)"].to_i, item["after_finished_at(3i)"].to_i, item["after_finished_at(4i)"].to_i, item["after_finished_at(5i)"].to_i)
      

        item[:request_at] = Time.current
       
        item[:request_type] = 1
        item[:request_status] = "0"
        item[:before_started_at] = attendance.started_at
        item[:before_finished_at] = attendance.finished_at
        attendance.update_attributes!(item)
        
      end
      
      
    end
    flash[:success] = "勤怠変更を申請しました。承認までしばらくお待ちください。"
    redirect_to new_user_attendance_url
  end
  
  
  def edit_confirm
    @attendance = Attendance.where(who_consent: current_user.id)
    @attendance_user_id = @attendance.pluck(:user_id)
    @user = User.new
    
    @users = {}
    @attendance_user_id.each do |user_id|
      @user = User.find_by(id: user_id)
      @user_attendance = @user.attendances.where(who_consent: current_user.id).where(request_type: 1).to_a
      @users.merge!(user_id => @user_attendance)
    end
 

  end
  
  def update
   
  end
 
 
 
 
  def destroy
  end
  
  
  private
  
    def attendance_edit_params
      params.require(:user).permit(attendances: [:after_started_at, :after_finished_at, :note, :who_consent, :tommorow_flag])[:attendances]
    end
    
    def update_edit_params
      params.require(:user).permit(attendances: [:before_started_at, :before_finished_at, :after_started_at, :after_finished_at, :request_status])[:attendances]
    end
    

  
end
