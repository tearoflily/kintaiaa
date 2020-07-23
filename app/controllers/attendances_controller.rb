class AttendancesController < ApplicationController
  before_action :set_one_month, except: [:working_now]
  before_action :no_access_admin, only: [:new, :create, :edit, :update_waiting]
  
  before_action :logged_in_user

  before_action :correct_user, only: [:new, :create, :attendance_log, :month_confirmation_create, :attendance_log_delete, :edit, :update_waiting, :overwork, :overwork_update, :month_confirmation_create]
  before_action :admin_user, only: [:working_now]
  before_action :superior_user, only: [:edit_confirm, :update, :overwork_confirm, :overwork_confirm_update, :month_confirmation, :month_confirmation_update]
  before_action :set_select_who_consent, only: [:edit, :update_waiting]

  

  def new #勤怠一覧画面

      who_consent_month_confirm = @attendances.pluck(:month_work_who_consent).uniq
      who_consent_edit_confirm = @attendances.pluck(:who_consent).uniq
      who_consent = who_consent_month_confirm.push(who_consent_edit_confirm)
      who = who_consent.flatten!
      who_uniq = who.uniq.map(&:to_i)
  
  
   @user = User.find(params[:user_id])
   @attendance_month_work = @user.attendances.new
   
   
   if params[:format].present? && (!params[:format] == "work_view") && who_uniq.include?(current_user.id)

     respond_to do |format|
       format.csv do
         send_data render_to_string, filename: "attendances.csv", type: :csv
         
       end
     end
   end
  end
  

  
  def create #勤怠一覧画面 「出勤」「退勤」ボタン押下時処理
    @user = User.find(params[:user_id])
    @today = Date.current
    @attendance = @user.attendances.find_by(worked_on: params[:dayid])
    
      
    if @attendance.started_at.nil? 
      if @attendance.update_attribute(:started_at, Time.current)
        flash.now[:success] = "おはようございます"
        redirect_to new_user_attendance_path @user
      else
        flash[:danger] = "出勤登録失敗"
        render :new
      end
      
    elsif @attendance.finished_at.nil?
     
      started_at_check = @attendance.started_at
      started_at_range = started_at_check + 1.days
      tommorow_end_of_day = started_at_range.end_of_day
      tommorow_beginning_of_day = tommorow_end_of_day.beginning_of_day
      
      today_end_of_day = @attendance.started_at.end_of_day
      today_beginning_of_day = today_end_of_day.beginning_of_day
      
      if Time.current.between?(today_beginning_of_day,today_end_of_day)
        @attendance.tommorow = "0"
        
        if @attendance.update_attribute(:finished_at, Time.current)
          flash[:success] = "おつかれさまでした"
          redirect_to new_user_attendance_path @user
        else
          flash[:danger] = "退勤登録失敗1"
          render :new
        end
        
      elsif Time.current.between?(tommorow_beginning_of_day,tommorow_end_of_day)
        @attendance.tommorow = "1"
        
        if @attendance.update_attribute(:finished_at, Time.current)
          
          flash[:success] = "おつかれさまでした"
          redirect_to new_user_attendance_path @user
        else
          flash[:danger] = "退勤登録失敗2"
          render :new
        end
        
      else
        flash[:danger] = "退勤登録に失敗しました。出社日時の翌日までの範囲が有効です。編集画面で正しい退勤時間を登録してください。"
        render :new
      end
    
    end
    
  end
  
  
  def month_confirmation_create #勤怠一覧画面 右下 1ヶ月分の勤怠申請ボタン 押下時処理
    if params[:attendance][:month_work_who_consent].present?
      @user = User.find(params[:user_id])
      first_day = params[:dayid]
      first_day = first_day.to_date
       
      last_day = first_day.end_of_month
      attendance_month = @user.attendances.where(worked_on: first_day..last_day)
      
      attendance_month.each do |item|
        attendance = Attendance.find_by(id: item.id)
    
        attendance[:month_work_who_consent] = params[:attendance][:month_work_who_consent]
        attendance[:month_work] = 0
      
        if attendance.save!
          flash[:success] = "1ヶ月分勤怠の承認申請を送信しました。"
          redirect_to new_user_attendance_path and return
        else
          flash[:danger] = "1ヶ月分勤怠の承認申請を送信できませんでした。"
          render :new
        end
      end
    end 
    
  end
  

  
  def edit #勤怠編集画面
    @attendance = @user.attendances.find_by(user_id: current_user.id)

  end
  
  def set_select_who_consent
    @select_attendance = User.where(superior: true).where.not(id: current_user.id).where.not(admin: true)
  end
  

 

  
  def update_waiting # 勤怠編集画面　送信処理
       ActiveRecord::Base.transaction do
          @user = User.find(params[:user_id])
      
          attendance_edit_params.each do |key, item|
          
            if item[:who_consent].present? && item["after_started_at(4i)"].present? && item["after_started_at(5i)"].present? && item["after_finished_at(4i)"].present? && item["after_finished_at(5i)"].present?
              @attendance = Attendance.find(key)
    
                    year = @attendance[:worked_on].year
                    month = @attendance[:worked_on].month
                    day = @attendance.worked_on.day
                    
                    at_after_started_at = Time.new(year.to_i, month.to_i, day.to_i, item["after_started_at(4i)"].to_i, item["after_started_at(5i)"].to_i)
                    at_after_finished_at = Time.new(year.to_i, month.to_i, day.to_i, item["after_finished_at(4i)"].to_i, item["after_finished_at(5i)"].to_i)
                    
                    at_after_started_at = nil if item["after_started_at(5i)"].blank?
                    at_after_finished_at = nil if item["after_finished_at(5i)"].blank?
                    
                    @attendance[:after_started_at] = at_after_started_at
                    @attendance[:after_finished_at] = at_after_finished_at
              

              unless (@attendance[:started_at] == @attendance[:after_started_at]) && (@attendance[:finished_at] == @attendance[:after_finished_at])
             
                
                    @attendance[:request_at] = Time.current
                   
                    @attendance[:request_type] = 1
                    @attendance[:request_status] = 0
                  
                    @attendance[:before_started_at] = @attendance[:started_at]
                    @attendance[:before_finished_at] = @attendance[:finished_at]
                 
                    @attendance[:who_consent] = item[:who_consent]
                
                    @attendance[:tommorow_flag] = item[:tommorow_flag]
                    @attendance[:note_temporary] = item[:note_temporary]
             
                    @attendance.save!
                   
              end
              
            elsif item[:who_consent].nil? && item["after_started_at(4i)"].present? && item["after_started_at(5i)"].present? && item["after_finished_at(4i)"].present? && item["after_finished_at(5i)"].present?
                  
                  flash.now[:danger] = "指示者を選択してください"
                  raise    
            elsif item[:who_consent].present? && item["after_started_at(4i)"].nil? || item["after_started_at(5i)"].nil? || item["after_finished_at(4i)"].nil? || item["after_finished_at(5i)"].nil?
                  
                  flash.now[:danger] = "指示者が選択されていますが、出社時間or退社時間に不備があります。"
                  raise
            elsif item[:who_consent].nil? && item["after_started_at(4i)"].present? || item["after_started_at(5i)"].present? || item["after_finished_at(4i)"].present? || item["after_finished_at(5i)"].present?
                  
                  flash.now[:danger] = "指示者が選択されていますが、出社時間or退社時間に不備があります。"
                  raise
            end
          end
       end
       flash[:success] = "変更申請を送信しました。承認まで今しばらくお待ちください。"
       redirect_to user_attendances_edit_path
  rescue ActiveRecord::RecordInvalid
     flash.now[:danger] = "無効な入力データがあった為、更新をキャンセルしました。"
     render :edit
  rescue RuntimeError
     redirect_to user_attendances_edit_path, flash: { danger: "無効な入力データがあったため、登録出来ませんでした。" } and return
  end
  
  
  def edit_confirm #勤怠変更の承認画面
  
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
  
  def update #勤怠変更承認時の処理
    ActiveRecord::Base.transaction do
      update_edit_params.each do |id, item|
     
          item[:request_status] = item[:request_status].to_i
          if item[:ok_flag] == "0"
            
          elsif item[:ok_flag] == "1" && item[:request_status] == 1
      
            attendance = Attendance.find_by(id: id)
            @user = User.find_by(id: attendance.user_id)
            @new_attendance = @user.attendances.new
              
                @new_attendance[:started_at] = attendance.after_started_at
                @new_attendance[:finished_at] = attendance.after_finished_at
                @new_attendance[:before_started_at] = attendance.before_started_at
                @new_attendance[:before_finished_at] = attendance.before_finished_at
                @new_attendance[:who_consent] = attendance.who_consent
                @new_attendance[:request_at] = Time.current
          
                @new_attendance[:worked_on] = attendance[:worked_on]
                @new_attendance[:note] = attendance.note_temporary
                @new_attendance[:request_type] = attendance.request_type
                @new_attendance[:request_status] = 1
               
      
                @new_attendance[:tommorow] = attendance[:tommorow_flag]
                @new_attendance[:tommorow_flag] = attendance[:tommorow]
  
                
                @new_attendance[:only_day] = 1
                
                @new_attendance.save!
  
                attendance[:started_at] = attendance[:after_started_at]
                attendance[:finished_at] = attendance[:after_finished_at]
                attendance[:request_at] = Time.current
                attendance[:request_type] = attendance.request_type
                attendance[:only_day] = nil
                attendance[:note] = attendance[:note_temporary]
                attendance[:request_status] = 3
                attendance[:tommorow] = attendance[:tommorow]
              
                if attendance.save!(context: :hoge)
                  flash[:success] = "承認が完了しました"
              
                else  
                  flash[:danger] = "更新に失敗しました"
                  
                end

          elsif item[:ok_flag] == "1" && item[:request_status] == 8
            flash.now[:success] = "勤怠情報の変更が完了していません。(「なし」を選択しています)"
          elsif item[:request_status] == 2
            attendance = Attendance.find_by(id: id)
            attendance[:after_started_at] = nil
            attendance[:after_finished_at] = nil
            attendance[:before_started_at] = nil
            attendance[:before_finished_at] = nil
            attendance[:request_at] = nil
            attendance[:request_type] = 1
            attendance[:note_temporary] = nil
            attendance[:tommorow_flag] = nil
            attendance[:request_status] = 2
          
            attendance.save!

            
          end
          
          
      end
    end
    redirect_to new_user_attendance_path, flash: { success: "勤怠情報の承認or否認の回答が完了しました" }
  rescue ActiveRecord::RecordInvalid
    flash.now[:danger] = "勤怠情報の変更が完了していません。"
    redirect_to new_user_attendance_path
  rescue RuntimeError
    
    redirect_to new_user_attendance_path, flash: { danger: "勤怠情報の変更が完了していません。入力に不備があります" }
  end
  
  
  
  def attendance_log #勤怠変更ログ画面
    @user = User.find(current_user.id)
    
      if params[:worked_on_between].present?
        @search_date = Time.new(params[:worked_on_between][:"date(1i)"].to_i, params[:worked_on_between][:"date(2i)"].to_i, params[:worked_on_between][:"date(3i)"].to_i)
      end
    

    
    @attendance = @user.attendances.order(:created_at).where("(request_status = ?)", 3).where("only_day is null").search(@search_date)
   
    @attendance_default = @attendance.pluck(:worked_on).first
    
  end
  
  def attendance_log_delete
   
    @user = User.find(params[:user_id])
    
    day = params[:format]
    day_to_date = day.to_date
    month_start = day_to_date.beginning_of_month
    month_end = month_start.end_of_month

    log_delete_month = @user.attendances.where(worked_on: month_start..month_end)
    log_delete_month.each do |id, log_day|
    
      attendance = Attendance.find_by(id: id)
      
      unless attendance.only_day == 1 && attendance.started_at.nil?
        attendance[:before_started_at] = nil
        attendance[:before_finished_at] = nil
        attendance[:after_started_at] = nil
        attendance[:after_finished_at] = nil
        attendance[:request_status] = nil
 
  
        attendance.save
      end
      
      
    end
    redirect_to attendance_log_user_attendances_url
    flash[:success] = "該当月のログを消去しました"
  end
  
  def overwork #残業申請 画面
    @user = User.find(params[:user_id])
    @attendance = @user.attendances.find_by(id: params[:id])
  end
  

  def overwork_update #残業申請 送信処理
    if params[:attendance][:who_consent].present?
      @user = User.find(params[:user_id])
      @attendance = Attendance.find(params[:id])
      
      year = @attendance.worked_on.year
      month = @attendance.worked_on.month
      day = @attendance.worked_on.day

      @attendance.after_finished_at = Time.new(year.to_i, month.to_i, day.to_i, params[:attendance]["after_finished_at(4i)"].to_i, params[:attendance]["after_finished_at(5i)"].to_i)
      @attendance.after_started_at = @attendance.started_at
      @attendance.request_at = Time.current
      @attendance.note_temporary = params[:attendance][:note_temporary]
      @attendance.request_type = 2
      @attendance.request_status = 0
      @attendance.before_finished_at = @attendance.finished_at
      @attendance.before_started_at = @attendance.started_at
      @attendance.tommorow_flag = params[:attendance][:tommorow_flag]
      @attendance.who_consent = params[:attendance][:who_consent]
    
      user_finished_at = User.find(@attendance.user_id)
      month = @attendance.worked_on
      
      user_basic_finished_at_datetime = DateTime.new(month.year.to_i, month.month.to_i, month.day.to_i, user_finished_at.designated_work_end_time.hour.to_i, user_finished_at.designated_work_end_time.min.to_i, user_finished_at.designated_work_end_time.sec.to_i, "JST")

      
      if @attendance.tommorow_flag == "1"
        @attendance.after_finished_at = @attendance.after_finished_at + 1.days
      end
      
      
      if @attendance.after_finished_at > user_basic_finished_at_datetime
        @attendance.save!
        flash[:success] = "残業申請を送信しました"
        redirect_to new_user_attendance_path
      elsif @attendance.after_finished_at < user_basic_finished_at_datetime
        flash[:danger] = "残業の申請時間に不備があります(基本勤務終了時間を超えた時間で申請してください)"
        redirect_to new_user_attendance_path
      else
        flash[:danger] = "残業申請を送信できませんでした"
        redirect_to new_user_attendance_path
      end
    elsif params[:attendance][:who_consent].blank?
      flash[:danger] = "残業申請をするときは指示者名の選択が必須です"
      redirect_to new_user_attendance_path
    end
  end
  
  def overwork_confirm #残業申請 承認画面
    @user = User.find(params[:user_id])
    attendance_all = Attendance.where(who_consent: current_user.id).where(request_status: 0).where(request_type: 2).to_a
    attendance_user_id = attendance_all.pluck(:user_id)
    user_new = User.new
    @attendance = Attendance.new
    
    @users = {}
    attendance_user_id.each do |user_id|
   
      user_new = User.find_by(id: user_id)
      user_attendance = user_new.attendances.where(who_consent: current_user.id).where(request_status: 0).where(request_type: 2).to_a
      
      @users.merge!(user_id => user_attendance)
    end
  end
  
  
  
  
  def overwork_confirm_update #残業申請 承認処理
   
    update_overwork_edit_params.each do |id, item|
      
      item[:request_status] = item[:request_status].to_i

      if item[:ok_flag] == "1" && ( item[:request_status] == 1 or item[:request_status] == 2 )
    
          attendance = Attendance.find_by(id: id)
          @user = User.find_by(id: attendance.user_id)
 
        if item[:request_status] == 1
          
        
          @attendance = @user.attendances.new
        
          @attendance.started_at = attendance.before_started_at
          

          @attendance.note = attendance.note_temporary
          @attendance.finished_at = attendance[:after_finished_at]
          @attendance.who_consent = attendance.who_consent
          @attendance.worked_on = attendance[:worked_on]
          @attendance.request_type = 2
          @attendance.request_status = 1
          
          @attendance.tommorow = item[:tommorow_flag]
          @attendance.only_day = 1
          
          @attendance.before_started_at = attendance.started_at
          @attendance.before_finished_at = attendance.finished_at
          @attendance.tommorow_flag = attendance.tommorow
          
          attendance.started_at = attendance.after_started_at
          attendance.finished_at = attendance.after_finished_at
          attendance.request_at = Time.current
          attendance.request_status = 3
          attendance.only_day = nil
          attendance.note = attendance.note_temporary

          attendance.save!

          if @attendance.save!
            
            flash[:success] = "残業申請の承認が完了しました"
            redirect_to(new_user_attendance_url) and return
           
          else
            flash[:danger] = "残業申請の承認が完了していません。"
            session[:error] = @attendance.errors.full_messages
            redirect_to overwork_confirm_user_attendances_path and return
          end 
        elsif item[:request_status] == 2

          attendance.after_started_at = nil
          attendance.after_finished_at = nil
          attendance.before_started_at = nil
          attendance.before_finished_at = nil
          attendance.request_at = nil
          attendance.request_type = 2
          attendance.note_temporary = nil
          attendance.tommorow_flag = nil
          attendance.request_status = 2
        
          attendance.save!
          
          redirect_to new_user_attendance_path and return
          flash.now[:success] = "変更しました"
          
        elsif item[:request_status] == 0
          flash[:danger] = "指示者確認印が変更されていません"
          render :overwork_confirm
        end
      elsif item[:request_status] == 0
        flash[:danger] = "残業承認をする時は「承認」または「否認」を選択してください"
        
      elsif item[:ok_flag] == "0"
        flash[:danger] = "変更ボックスにチェックをつけてください"

      elsif item[:request_status] == 8
        flash[:info] = "「なし」を選択しました"
        redirect_to new_user_attendance_path and return
      end
      
    end
    redirect_to new_user_attendance_path and return
  end
  
  def month_confirmation #1ヶ月分の勤怠 承認画面
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
  
  def month_confirmation_update #1ヶ月分の勤怠承認処理
    ActiveRecord::Base.transaction do
      
      update_month_edit_params.each do |key, item|
  
        item[:month_work] = item[:month_work].to_i
        if item[:month_work] == 1 && item[:ok_flag] == "1"
          
          @attendance_month = Attendance.find_by(id: key)
          @user = User.find_by(id: @attendance_month.user_id)
          @month_start = @attendance_month.worked_on.beginning_of_month
          @month_end = @month_start.end_of_month
          @month = @user.attendances.where(worked_on: @month_start..@month_end)
          @month.each do | day |
            attendance = Attendance.find(day.id)
            attendance.month_work = 1
            attendance.save!
          end
        elsif item[:month_work] == 2 && item[:ok_flag] == "1"
          @attendance_month = Attendance.find_by(id: key)
          @user = User.find_by(id: @attendance_month.user_id)
          @month_start = @attendance_month.worked_on.beginning_of_month
          @month_end = @month_start.end_of_month
          @month = @user.attendances.where(worked_on: @month_start..@month_end)
          @month.each do | day |
            attendance = Attendance.find(day.id)
            attendance.month_work = 2
            attendance.save!
            redirect_to new_user_attendance_path(current_user) and return
          end
        elsif item[:month_work] == 0 && item[:ok_flag] == "1"
          flash[:danger] = "「承認」or「否認」を選択してください"
          redirect_to new_user_attendance_path(current_user) and return
        elsif item[:ok_flag] == "0"
          flash[:danger] = "変更チェックボタンを押してください"
          redirect_to new_user_attendance_path(current_user) and return
        elsif item[:month_work] == 8 && item[:ok_flag] == "1"
          flash[:info] = "「なし」を選択しました"
          redirect_to new_user_attendance_path(current_user) and return
        end
        flash[:success] = "一ヶ月勤怠の承認および否認の回答が完了しました"
        redirect_to new_user_attendance_path(current_user) and return

      end
      
    end
  rescue ActiveRecord::RecordInvalid
    flash[:danger] = "一ヶ月勤怠の承認が失敗しました"
    redirect_to new_user_attendance_path(current_user) and return
  end
  
  
  
  
  def working_now # 現在出勤中の社員一覧
    @attendance = Attendance.where.not(started_at: nil).where(finished_at: nil)
    @attendance_user_id = @attendance.pluck(:user_id).uniq
    
    @users = {}
    @attendance_user_id.each do |user_id|
    
      user = User.find(user_id)
      @users.merge!(user.employee_number => user.name)
      
    end
  end
 
  def work_basic_edit
  
  end
 
 
  def destroy
  end
  
  
  private
  
    def attendance_edit_params
      params.require(:user).permit(attendances: [:worked_on, :after_started_at, :after_finished_at, :note_temporary, :who_consent, :tommorow_flag, :tommorow])[:attendances]
    end
    
    def update_edit_params
      params.require(:user).permit(attendances: [:worked_on, :request_status, :ok_flag, :only_day, :tommorow, :tommorow_flag, :note_temporary, :note])[:attendances]
    end
    
    def overwork_edit_params
      params.permit(:after_finished_at, :tommorow_flag, :note_temporary, :who_consent)
    end
    
    def update_overwork_edit_params
      params.require(:user).permit(attendances: [:worked_on, :after_finished_at, :request_status, :tommorow, :tommorow_flag, :note_temporary, :ok_flag])[:attendances]
    end
    
    def update_month_edit_params
      params.require(:user).permit(attendances: [:month, :month_work, :ok_flag])[:attendances]
    end
    
    def update_waiting_parmas 
      params.permit(:after_started_at, :after_finished_at, :request_at, :request_type, :request_status, :before_started_at, :before_finished_at, :note_temporary, :who_consent, :tommorow_flag)
    end
    
    def no_access_admin
      if current_user.admin?
        redirect_to root_url, flash: { danger: "管理者がアクセスできないページです。" }
      end
    end
    
    def admin_or_superior_user
      @user = User.find(params[:user_id]) if @user.blank?
      unless current_user.superior? || current_user.admin?
        flash[:danger] = "編集権限がありません。"
        redirect_to root_url
      end
    end
    
end
