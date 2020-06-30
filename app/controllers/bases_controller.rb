class BasesController < ApplicationController
  
  def index
    @bases = Base.all
    @base_create = Base.new 
  end
  
  def create
    @bases = Base.new(base_params)
    @bases.save
  end
  
  def edit
    @base = Base.find(params[:id])
  end
  
  def update
    @base = Base.find(params[:id])
    @base.update_attributes(base_params)
    
  end
  
  def destroy
    @base = Base.find(params[:id])
    @base.destroy
  end

private
  def base_params
    params.require(:base).permit(:base_number, :base_name, :base_type)
  end

  
end
