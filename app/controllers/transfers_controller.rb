class TransfersController < ApplicationController
	before_action :require_user
  before_action :set_transfer, only: [:show, :destroy, :edit, :update]
  before_action :set_league
  before_action :set_back_url

	def new
		@transfer = Transfer.new
    @transfer.transfer_items.build
  end

  def create
  	@transfer = Transfer.new(transfer_params)
    if @transfer.save
      flash[:success] = "Transfer initiated."
      transfer_item_params = params[:transfer][:transfer_item]
      
      TransferItem.create(transfer: @transfer,
        sending_team_id: transfer_item_params[:sending_team_id],
        receiving_team_id: transfer_item_params[:receiving_team_id],
        transfer_item_type: "Player",
        team_player_id: transfer_item_params[:team_player_id])
      
      TransferItem.create(transfer: @transfer,
        sending_team_id: transfer_item_params[:receiving_team_id],
        receiving_team_id: transfer_item_params[:sending_team_id],
        transfer_item_type: "Cash",
        cash_cents: transfer_item_params[:cash_cents])
      
      redirect_to league_transfers_path(@league)
      NewsItem.create(league: @league, news_item_resource_type: 'Transfer', news_item_resource_id: @transfer.id, body: "Transfer initiated by #{@transfer.primary_team.title}")
    else
      flash[:error] = "There was a problem initiating that transfer."
      redirect_to league_transfers_path(@league, @transfer)
    end
	end

  def index
    @transfers = Transfer.joins("INNER JOIN teams AS p_team ON p_team.id = transfers.primary_team_id").where(:p_team => {:league_id => League.find(params[:league_id])})
  end

  def edit
    @transfer = Transfer.find(params[:id])
    @team_player = @transfer.transfer_items.where(transfer_item_type: 'Player').first.team_player
    @cash_offer = @transfer.transfer_items.where(transfer_item_type: 'Cash').first.cash_cents
  end

  def update
    @cash_transfer_item = @transfer.transfer_items.where(transfer_item_type: 'Cash').first
    if @transfer.update(transfer_params) && @cash_transfer_item.update_attributes(cash_cents: params[:transfer][:transfer_item][:cash_cents])
      flash[:success] = "Updated transfer"
    else
      flash[:error] = @transfer.errors.full_messages.first
      flash[:error] = @cash_transfer_item.errors.full_messages.first
    end
    redirect_to league_transfers_path(@league)
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
    team_player_involved_in_transfer = @transfer.get_team_player_involved
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
    params.require(:transfer).permit(:primary_team_id, :secondary_team_id, :primary_team_accepted, :secondary_team_accepted, transfer_items_attributes: [:id, :transfer, :sending_team_id, :receiving_team_id, :transfer_item_type, :team_player_id, :cash_cents])
  end

  def set_transfer
    @transfer = Transfer.find(params[:id])
  end

  def set_league
    @league = League.find(params[:league_id])
  end

  def set_back_url
    session.delete(:return_to)
    @back_url = session[:return_to] ||= request.referer
  end
end
