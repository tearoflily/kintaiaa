class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  include SessionsHelper
  
  $days_of_the_week = %w{ 日 月 火 水 木 金 土}
  
  def set_one_month
    @first_day = params[:date].nil? ?
    Date.current.beginning_of_month : params[:date].to_date
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
    
  rescue ActiveRecord::RecordInvalid
      flash[:danger] = "ページ情報の取得に失敗しました。再度アクセスしてください"
      redirect_to root_url
  end
  
end
