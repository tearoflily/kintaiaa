class AttendancesController < ApplicationController
  before_action :set_one_month, except: [:working_now]



  def new
   @user = User.find(params[:user_id])
   @attendance_month_work = @user.attendances.new
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
  
  
  def month_confirmation_create
    unless params[:attendance][:month_work_who_consent].nil?
      @user = User.find(params[:user_id])
      first_day = params[:dayid]
      @first_day = first_day.to_date
       
      @last_day = @first_day.end_of_month
      @attendance_month = @user.attendances.where(worked_on: @first_day..@last_day)
      
      @attendance_month.each do |item|
        attendance = Attendance.find_by(id: item.id)
        attendance[:month_work_who_consent] = params[:attendance][:month_work_who_consent]
        attendance.month_work = 0
      
        attendance.save
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
      year = attendance.worked_on.year
      month = attendance.worked_on.month

      
      at_after_started_at = Time.new(year.to_i, month.to_i, item["after_started_at(3i)"].to_i, item["after_started_at(4i)"].to_i, item["after_started_at(5i)"].to_i)
      at_after_finished_at = Time.new(year.to_i, month.to_i, item["after_finished_at(3i)"].to_i, item["after_finished_at(4i)"].to_i, item["after_finished_at(5i)"].to_i)
      
      attendance.after_started_at = at_after_started_at.to_datetime
      attendance.after_finished_at = at_after_finished_at.to_datetime
     
      unless attendance.started_at == attendance.after_started_at

        attendance.request_at = Time.current
        attendance.request_type = 1
        attendance.request_status = "0"
        attendance.before_started_at = attendance.started_at
        attendance.before_finished_at = attendance.finished_at
        attendance.who_consent = item[:who_consent]
    
        attendance.save
        
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
          @new_attendance.request_at = Time.current
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
          
          if @new_attendance.save!
            flash.now[:success] = "勤怠情報の変更が完了しました"
           
          end
            flash.now[:danger] = "勤怠情報の変更が完了していません。"
        end
     
    end
  end
  
  def attendance_log
    @user = User.find(current_user.id)
    
      if params[:worked_on_between].present?
        @search_date = Time.new(params[:worked_on_between][:"date(1i)"].to_i, params[:worked_on_between][:"date(2i)"].to_i, params[:worked_on_between][:"date(3i)"].to_i)
      end
    
    @attendance = @user.attendances.order(:created_at).where("request_type = ?", 1).where("(request_status = ?)", 1).search(@search_date)
   
    @attendance_default = @attendance.pluck(:worked_on).first
    
  end
  
  def overwork
    @user = User.find(params[:user_id])
    @attendance = @user.attendances.find_by(id: params[:id])
  end
  

  def overwork_update
    @user = User.find(params[:user_id])
    attendance = Attendance.find(params[:id])
    
    year = attendance.worked_on.year
    month = attendance.worked_on.month
  
    attendance.after_finished_at = Time.new(year.to_i, month.to_i, params[:attendance]["after_finished_at(3i)"].to_i, params[:attendance]["after_finished_at(4i)"].to_i, params[:attendance]["after_finished_at(5i)"].to_i)
    attendance.after_finished_at.to_datetime
    attendance.request_at = Time.current
    attendance.request_type = 2
    attendance.request_status = "0"
    attendance.before_finished_at = attendance.finished_at
    attendance.before_started_at = attendance.started_at
    
    if attendance.save
      flash[:success] = "残業申請を送信しました"
      redirect_to new_user_attendance_path
    else
      render :overwork
    end
    
  end
  
  def overwork_confirm

    @attendance = Attendance.where(who_consent: current_user.id).where(request_status: 0).where(request_type: 2).to_a
    @attendance_user_id = @attendance.pluck(:user_id)
    @user = User.new
    
    @users = {}
    @attendance_user_id.each do |user_id|
    
      @user = User.find_by(id: user_id)
      @user_attendance = @user.attendances.where(who_consent: current_user.id).where(request_status: 0).where(request_type: 2).to_a
      
      @users.merge!(user_id => @user_attendance)
    end
  end
  
  def overwork_confirm_update
    
    update_overwork_edit_params.each do |id, item|
          attendance = Attendance.find_by(id: id)
          @user = User.find_by(id: attendance.user_id)

          
        if item[:request_status] == "1"

          @new_attendance = @user.attendances.new
  
          @new_attendance.started_at = attendance.before_started_at
          @new_attendance.finished_at = attendance.after_finished_at
          @new_attendance.who_consent = attendance.who_consent
          @new_attendance.worked_on = attendance[:worked_on]
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
  
          if @new_attendance.save!
            flash.now[:success] = "勤怠情報の変更が完了しました"
           
          end
            flash.now[:danger] = "勤怠情報の変更が完了していません。"
        elsif item[:request_status] == "2"

          attendance.after_started_at = nil
          attendance.after_finished_at = nil
          attendance.before_started_at = nil
          attendance.before_finished_at = nil
          attendance.request_at = nil
          attendance.request_type = nil
          attendance.only_day = nil
          attendance.request_status = 2
          attendance.request_status = 1
          attendance.save!
        end
     
    end
  end
  
  def month_confirmation
      @attendance_month = Attendance.where(month_work_who_consent: current_user.id).where(month_work: 0)
      @attendance_user_id = @attendance_month.pluck(:user_id)
      @user = User.new
     
      @users = {}
      @attendance_user_id.each do |user|
        @user = User.find_by(id: user)
        @user_attendance = @user.attendances.where(month_work_who_consent: current_user.id).where(month_work: 0).first

        
        @users.merge!(user => @user_attendance)
      end
  end
  
  def month_confirmation_update
  
    
    update_overwork_edit_params.each do |key, item|
     
      
      if item[:month_work] == "1" && item[:ok_flag] == "1"
        @attendance_month = Attendance.find_by(id: key)
        @user = User.find_by(id: @attendance_month.user_id)
        @month_start = @attendance_month.worked_on.beginning_of_month
        @month_end = @month_start.end_of_month
        @month = @user.attendances.where(worked_on: @month_start..@month_end)
        @month.each do | day |
          
          attendance = Attendance.find(day.id)
          
          attendance.month_work = 1
          
          attendance.save
          
        end
      end
      
    
    end
    

  end
  
  def working_now
    @attendance = Attendance.where.not(started_at: nil).where(finished_at: nil)
    @attendance_user_id = @attendance.pluck(:user_id).uniq
    
    @users = {}
    @attendance_user_id.each do |user_id|
    
      user = User.find(user_id)
      
     
      
      @users.merge!(user.id => user.name)
      
    end
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
    
    def overwork_edit_params
      params.permit(:after_finished_at, :tommorow_flag, :note, :who_consent)
    end
    
    def update_overwork_edit_params
      params.require(:user).permit(attendances: [:worked_on, :after_finished_at, :request_status])[:attendances]
    end
    
    def update_overwork_edit_params
      params.require(:user).permit(attendances: [:month, :month_work, :ok_flag])[:attendances]
    end


  
end
