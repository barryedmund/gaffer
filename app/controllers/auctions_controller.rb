class AuctionsController < InheritedResources::Base
  before_action :require_user
  before_action :set_team_player, only: [:create]

  def new
    @auction = Auction.new
  end

  def create
    @auction = Auction.new(auction_params)
    
    respond_to do |format|
      if @auction.save
        format.html { redirect_to league_auction_path(@auction.team_player.team.league.id, @auction), notice: 'Player transfer listed.' }
      else
        format.html { render :new }
      end
    end
  end

  private
  def auction_params
    params.require(:auction).permit(:team_player_id, :minimum_bid, :is_voluntary, :is_active)
  end

  def set_team_player
    @team_player = TeamPlayer.find(params[:auction][:team_player_id])
  end
end

