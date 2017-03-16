class TransferItemsController < ApplicationController
  before_action :require_user
  before_action :set_transfer_item, only: [:show, :destroy, :edit, :update]
  before_action :set_league
  before_action :set_transfer
  before_action :require_permission_to_change, only: [:edit, :update, :destroy]
  before_action :require_permission_to_create, only: [:create]
  before_action :update_transfer_status, only: [:edit, :update, :destroy]

  def new
    @transfer_item = TransferItem.new
  end

  def create
    @transfer_item = TransferItem.new(transfer_item_params)
    if @transfer_item.save
      update_transfer_status
      team_player_involved = @transfer_item.get_team_player_in_transfer
      flash[:success] = "Bid made for #{team_player_involved.full_name}"
      if team_player_involved.number_of_offers === 1
        team_player_involved.update_attribute(:transfer_completes_at, 3.days.from_now)
      end
      redirect_to league_transfer_path(@league, @transfer)
    else
      flash[:error] = @transfer_item.errors.full_messages.first
      redirect_to new_league_transfer_transfer_item_path(@transfer_item.get_league, @transfer_item.transfer, direct_bid: @transfer_item.transfer.get_player_transfer_item.team_player.id)
    end
  end

  def destroy
    if @transfer_item.destroy
      flash[:success] = "Transfer item was removed successfully."
    else
      flash[:error] = "Transfer item was not removed successfully."
    end
    redirect_to league_transfer_path(@league, @transfer)
  end

  def edit
  end

  def update
    if @transfer_item.update(transfer_item_params)
      flash[:success] = "Updated transfer item"
      redirect_to league_transfer_path(@league, @transfer)
    else
      flash[:error] = @transfer_item.errors.full_messages.first
      redirect_to league_transfer_path(@league, @transfer)
    end
  end

  private
  def transfer_item_params
    params.require(:transfer_item).permit(:sending_team_id, :receiving_team_id, :transfer_item_type, :team_player_id, :transfer_id, :cash_cents)
  end

  def set_transfer_item
    @transfer_item = TransferItem.find(params[:id])
  end

  def set_transfer
    @transfer = Transfer.find(params[:transfer_id])
  end

  def set_league
    @league = League.find(params[:league_id])
  end

  def require_permission_to_change
    if [@transfer_item.sending_team.user, @transfer_item.receiving_team.user].exclude?(current_user)
      redirect_to(league_transfers_path(@league), :notice => "Hey! You aren't involved in that transfer.")
    elsif @transfer.transfer_completed?
      redirect_to(league_transfers_path(@league), :notice => "That transfer is done and dusted.")
    end
  end

  def require_permission_to_create
    if [@transfer.primary_team.user, @transfer.secondary_team.user].exclude?(current_user)
      redirect_to(league_transfers_path(@league), :notice => "Hey! You aren't involved in that transfer.")
    elsif @transfer.transfer_completed?
      redirect_to(league_transfers_path(@league), :notice => "That transfer is done and dusted.")
    end
  end

  def update_transfer_status
    @transfer.reset_teams_transfer_status
  end
end
