class BasesController < ApplicationController
  before_action :logged_in_user
  before_action :admin_user

  
  def index
    @bases = Base.all
    @base_create = Base.new 
  end
  
  def create
    @bases = Base.new(base_params)
    @bases.save!
    flash[:success] = "拠点情報の登録が完了しました"
    redirect_to bases_url
  end
  
  def edit
    @base = Base.find(params[:id])
  end
  
  def update
    @base = Base.find(params[:id])
    @base.update_attributes(base_params)
    flash[:success] = "拠点情報の修正が完了しました"
    redirect_to bases_url
  end
  
  def destroy
    @base = Base.find(params[:id])
    @base.destroy
    flash[:success] = "拠点情報の削除が完了しました"
    redirect_to bases_url
  end

private
  def base_params
    params.require(:base).permit(:base_number, :base_name, :base_type)
  end

  
end
