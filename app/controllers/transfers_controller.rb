class TransfersController < ApplicationController
	before_action :require_user
  before_action :set_transfer, only: [:show, :destroy, :edit, :update]
  before_action :set_league

	def new
		@transfer = Transfer.new
    @transfer.transfer_items.build
  end

  def create
  	@transfer = Transfer.new(transfer_params)
    if @transfer.save
      flash[:success] = "Transfer initiated."
      # Has nested transfer_item details
      if params[:transfer].has_key?('transfer_item')
        transfer_item_params = params[:transfer][:transfer_item]
        TransferItem.create(transfer: @transfer, sending_team_id: transfer_item_params[:sending_team_id], receiving_team_id: transfer_item_params[:receiving_team_id], transfer_item_type: transfer_item_params[:transfer_item_type], team_player_id: transfer_item_params[:team_player_id])
        redirect_to new_league_transfer_transfer_item_path(@league, @transfer, direct_bid: transfer_item_params[:team_player_id])
      # Does not have nested transfer_item details
      else
        redirect_to new_league_transfer_transfer_item_path(@league, @transfer)
      end
      NewsItem.create(league: @league, news_item_resource_type: 'Transfer', news_item_resource_id: @transfer.id, body: "Transfer initiated by #{@transfer.primary_team.title}")
    else
      flash[:error] = "There was a problem initiating that transfer."
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
      flash[:success] = "Response changed."
    elsif @transfer.secondary_team.user == @current_user
      new_secondary_value = @transfer.secondary_team_accepted ? false : true
      @transfer.update_attributes(:secondary_team_accepted => new_secondary_value)
      flash[:success] = "Response changed."
    end
    if @transfer.transfer_completed?
      @transfer.complete_transfer
    end
    redirect_to :back
  end

  def destroy
    @transfer = Transfer.find(params[:id])
    team_player_involved_in_transfer = @transfer.get_player_transfer_item.get_team_player_in_transfer
    if @transfer.destroy
      if team_player_involved_in_transfer.number_of_offers === 0
        team_player_involved_in_transfer.update_attribute(:transfer_completes_at, nil)
      end
      flash[:success] = "Transfer was cancelled successfully."
    else
      flash[:error] = "Transfer was not cancelled successfully."
    end
    redirect_to league_transfers_path(@league)
  end

	private
  def transfer_params
    params.require(:transfer).permit(:primary_team_id, :secondary_team_id, :primary_team_accepted, :secondary_team_accepted, transfer_items_attributes: [:transfer, :sending_team_id, :receiving_team_id, :transfer_item_type, :team_player_id])
  end

  def set_transfer
    @transfer = Transfer.find(params[:id])
  end

  def set_league
    @league = League.find(params[:league_id])
  end
end
