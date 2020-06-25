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
        render :new
      end
    end
    
  end
  

  
  def edit
   
    @attendance = @user.attendances.find_by(user_id: current_user.id)
  end
  

 

  
  def update_waiting
    @user = User.find(params[:user_id])
    
   
    
    attendance_edit_params.each do |id, item|
     
      attendance = Attendance.find(id)
     
        item[:after_started_at] = DateTime.new(item["after_started_at(1i)"].to_i, item["after_started_at(2i)"].to_i, item["after_started_at(3i)"].to_i, item["after_started_at(4i)"].to_i, item["after_started_at(5i)"].to_i)
        item[:after_finished_at] = DateTime.new(item["after_finished_at(1i)"].to_i, item["after_finished_at(2i)"].to_i, item["after_finished_at(3i)"].to_i, item["after_finished_at(4i)"].to_i, item["after_finished_at(5i)"].to_i)
      
      unless attendance.started_at == item[:after_started_at] 

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
      @user_attendance = @user.attendances.where(who_consent: current_user.id).where(request_status: 0).where(request_type: 1).to_a
      
      @users.merge!(user_id => @user_attendance)
    end
 

  end
  
  def update
    update_edit_params.each do |id, item|

        if item[:ok_flag] == "1" && item[:request_status] == "1"
  
          attendance = Attendance.find_by(id: id)
          @user = User.find_by(id: attendance.user_id)
          @new_attendance = @user.attendances.new

          @new_attendance.started_at = attendance.after_started_at
          @new_attendance.finished_at = attendance.after_finished_at
          @new_attendance.before_started_at = attendance.before_started_at
          @new_attendance.before_finished_at = attendance.before_finished_at
          @new_attendance.who_consent = attendance.who_consent
          @new_attendance.request_at = DateTime.current
          @new_attendance.worked_on = item[:worked_on]
          @new_attendance.note = attendance.note
          @new_attendance.request_type = attendance.request_type
          @new_attendance.request_status = 1
          @new_attendance.tommorow_flag = attendance.tommorow_flag
          @new_attendance.only_day = 1
          
          attendance.after_started_at = nil
          attendance.after_finished_at = nil
          attendance.before_started_at = nil
          attendance.before_finished_at = nil
          attendance.who_consent = nil
          attendance.request_at = nil
          attendance.request_type = nil
          attendance.only_day = nil
          attendance.request_status = nil
          
          attendance.save!
          @new_attendance.save!
        end
     
    end
  end
  
  def log
    @user = User.find(current_user.id)
  
    @attendance = @user.attendances.order(:created_at).where("(request_status = ?)", 1)
    
    # https://teratail.com/questions/214779
    
  end
 
 
 
 
  def destroy
  end
  
  
  private
  
    def attendance_edit_params
      params.require(:user).permit(attendances: [:after_started_at, :after_finished_at, :note, :who_consent, :tommorow_flag])[:attendances]
    end
    
    def update_edit_params
      params.require(:user).permit(attendances: [:worked_on, :request_status, :ok_flag])[:attendances]
    end
    

  
end
