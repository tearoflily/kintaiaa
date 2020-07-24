class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  include SessionsHelper
  
  $days_of_the_week = %w{ 日 月 火 水 木 金 土}
  
  def set_one_month
    @first_day = params[:date].nil? ?
    Date.current.beginning_of_month : params[:date].to_date
    
    if params[:day_id].present?
      @first_day = params[:day_id].to_date.beginning_of_month
    end
    
    @last_day = @first_day.end_of_month
    one_month = [*@first_day..@last_day]
    
    @user = User.find(params[:user_id])
    @attendances = @user.attendances.where(worked_on: @first_day..@last_day).order(:worked_on)

    unless one_month.count == @attendances.count && @attendances.pluck(:started_at).present?
      ActiveRecord::Base.transaction do
   
        one_month.each { |day| @user.attendances.create!(worked_on: day, started_at: nil, finished_at: nil, only_day: 1, request_status: nil) unless @attendances.pluck(:worked_on).include? day }
      end
      
      @attendances = @user.attendances.where(worked_on: @first_day..@last_day).order(:worked_on)

      
    end

    @work_day_count = @attendances.where(only_day: 1).where('started_at IS NOT NULL').count
    
  rescue ActiveRecord::RecordInvalid
      flash[:danger] = "ページ情報の取得に失敗しました。再度アクセスしてください "
      redirect_to root_url
  end
  
  
  
  def logged_in_user
    unless logged_in?
      flash[:danger] = "ログインしてください"
      redirect_to login_url
    end
  end
  
  def correct_user
   
    unless current_user?(@user)
        flash[:danger] = "ログイン中のユーザー自身の勤怠画面のみ表示可能です。"
        redirect_to root_url
    end
  end
  
  def superior_user
    redirect_to root_url unless current_user.superior?
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
      flash[:danger] = "編集権限がありません"
      redirect_to(root_url)
    end
  end
  
end
