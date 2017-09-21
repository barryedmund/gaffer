class TransfersController < ApplicationController
	before_action :require_user
  before_action :set_transfer, only: [:show, :destroy, :edit, :update]
  before_action :set_league
  before_action :set_back_url
  before_action :get_current_user_team, only: [:new, :edit]

	def new
		@transfer = Transfer.new
    @transfer.transfer_items.build
  end

  def create
  	@transfer = Transfer.new(transfer_params)
    transfer_item_params = params[:transfer][:transfer_item]
    @transfer_item_cash = TransferItem.new(transfer: @transfer,
      sending_team_id: transfer_item_params[:sending_team_id],
      receiving_team_id: transfer_item_params[:receiving_team_id],
      transfer_item_type: "Cash",
      cash_cents: transfer_item_params[:cash_cents])
    @transfer_item_player = TransferItem.new(transfer: @transfer,
      sending_team_id: transfer_item_params[:receiving_team_id],
      receiving_team_id: transfer_item_params[:sending_team_id],
      transfer_item_type: "Player",
      team_player_id: transfer_item_params[:team_player_id])
    if @transfer_item_player.valid? && @transfer_item_cash.valid? && @transfer.save
      @transfer_item_player.save
      @transfer_item_cash.save
      team_player = @transfer.get_team_player_involved
      if @transfer.is_a_transfer_listing && team_player.transfer_minimum_bid && @transfer_item_cash.cash_cents >= team_player.transfer_minimum_bid && team_player.number_of_offers == 1
        team_player.update_attributes!(transfer_completes_at: 3.days.from_now)
      end
      flash[:success] = "Transfer initiated."
      redirect_to league_transfers_path(@league)
      NewsItem.create(league: @league, news_item_resource_type: 'Transfer', news_item_resource_id: @transfer.id, body: "Transfer initiated by #{@transfer.primary_team.title}")
    else
      error_message = "Unable to create that transfer."
      cash_sending_team = @transfer_item_cash.sending_team
      if @transfer_item_cash.cash_cents && @transfer_item_cash.cash_cents > cash_sending_team.cash_balance_cents
        error_message = "#{cash_sending_team.title} does not have enough funds."
      end
      flash[:error] = error_message
      redirect_to league_transfers_path(@league)
    end
	end

  def index
    @transfers = Transfer.joins("INNER JOIN teams AS p_team ON p_team.id = transfers.primary_team_id").where(:p_team => {:league_id => League.find(params[:league_id])})
  end

  def edit
    @transfer = Transfer.find(params[:id])
    @team_player = @transfer.transfer_items.where(transfer_item_type: 'Player').first.team_player
    @cash_offer = @transfer.transfer_items.where(transfer_item_type: 'Cash').first.cash_cents
    @primary_team = @transfer.primary_team
    @secondary_team = @transfer.secondary_team
  end

  def update
    @cash_transfer_item = @transfer.transfer_items.where(transfer_item_type: 'Cash').first
    if @transfer.update(transfer_params) && @cash_transfer_item.update_attributes(cash_cents: params[:transfer][:transfer_item][:cash_cents])
      team_player = @transfer.get_team_player_involved
      if @transfer.is_a_transfer_listing && team_player.transfer_minimum_bid
        if @cash_transfer_item.cash_cents >= team_player.transfer_minimum_bid
          if team_player.transfer_completes_at == nil
            team_player.update_attributes!(transfer_completes_at: 3.days.from_now)
          end
        else
          if team_player.transfer_completes_at != nil
            if (team_player.number_of_offers == 1) || (team_player.number_of_offers > 1 && team_player.get_winning_transfer.get_cash_involved < team_player.transfer_minimum_bid)
              team_player.update_attributes!(transfer_completes_at: nil)
            end
          end
        end
      end
      flash[:success] = "Updated transfer"
    else
      flash[:error] = @transfer.errors.full_messages.first
      flash[:error] = @cash_transfer_item.errors.full_messages.first
    end
    redirect_to league_transfers_path(@league)
  end

  def change_response
    @transfer = Transfer.find(params[:id])
    if @transfer.primary_team.user == current_user
      new_primary_value = @transfer.primary_team_accepted ? false : true
      @transfer.update_attributes(:primary_team_accepted => new_primary_value)
      flash[:success] = "Response changed."
    elsif @transfer.secondary_team.user == current_user
      new_secondary_value = @transfer.secondary_team_accepted ? false : true
      @transfer.update_attributes(:secondary_team_accepted => new_secondary_value)
      flash[:success] = "Response changed."
    end
    if @transfer.transfer_completed?
      @transfer.complete_transfer
    end
    redirect_to :back
  rescue ActionController::RedirectBackError
    redirect_to root_path
  end

  def destroy
    @transfer = Transfer.find(params[:id])
    team_player_involved_in_transfer = @transfer.get_team_player_involved
    if @transfer.destroy
      if team_player_involved_in_transfer.number_of_offers == 0
        team_player_involved_in_transfer.update_attributes!(transfer_completes_at: nil)
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

  def get_current_user_team
    @current_user_team = @current_user.get_team(@league)
  end
end
