class AllocationsController < ApplicationController
  before_action :set_grant, only: %i[ new create ]

  def new
    @allocation = @grant.allocations.new
  end

  def create
    @allocation = @grant.allocations.new(allocation_params)

    respond_to do |format|
      if @allocation.save
        format.html { redirect_to @grant }
      else
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  private
    def set_grant
      @grant = Grant.find(params[:grant_id])
    end

    def allocation_params
      params.require(:allocation).permit(:host, :vcpu)
    end
end
