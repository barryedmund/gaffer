class TransfersController < ApplicationController
	before_action :require_user
  before_action :set_transfer, only: [:show]
  before_action :set_league

	def new
		@transfer = Transfer.new
  end

  def create
  	@transfer = Transfer.new(transfer_params)
    if @transfer.save
      flash[:success] = "Created transfer"
      redirect_to new_league_transfer_transfer_item_path(@league, @transfer)
    else
      flash[:error] = "There was a problem creating that transfer."
      redirect_to league_transfers_path(@league)
    end
	end

  def index
    @transfers = Transfer.joins("INNER JOIN teams AS p_team ON p_team.id = transfers.primary_team_id").where(:p_team => {:league_id => League.find(params[:league_id])})
  end

  def change_response
    @transfer = Transfer.find(params[:id])
    if @transfer.primary_team.user == @current_user
      new_primary_value = @transfer.primary_team_accepted ? false : true
      @transfer.update_attributes(:primary_team_accepted => new_primary_value)
    elsif @transfer.secondary_team.user == @current_user
      new_secondary_value = @transfer.secondary_team_accepted ? false : true
      @transfer.update_attributes(:secondary_team_accepted => new_secondary_value)
    end
    if @transfer.transfer_completed?
      @transfer.complete_transfer
    end
    redirect_to :back
  end

  def destroy
    @transfer = Transfer.find(params[:id])
    if @transfer.destroy
      flash[:success] = "Transfer was cancelled successfully."
    else
      flash[:error] = "Transfer was not cancelled successfully."
    end
    redirect_to :back
  end

	private
  def transfer_params
    params.require(:transfer).permit(:primary_team_id, :secondary_team_id, :primary_team_accepted, :secondary_team_accepted)
  end

  def set_transfer
    @transfer = Transfer.find(params[:id])
  end

  def set_league
    @league = League.find(params[:league_id])
  end
end
