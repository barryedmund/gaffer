 class LeagueSeasonsController < ApplicationController

  def new
    @league_season = LeagueSeason.new
  end

  def create
    @league_season = LeagueSeason.new(league_id: params[:league_id], season_id: params[:season_id])
    if @league_season.save
      flash[:success] = "Season started"
      LeagueInvite.where(league: League.find_by(id: params[:league_id])).destroy_all
      redirect_to league_path(@league_season.league_id)
    else
      redirect_to league_path(@league_season.league_id)
    end
  end

  private
  def league_season_params
    params.require(:league_season).permit(:season_id, :league_id)
  end
 end
