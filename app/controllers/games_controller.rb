class GamesController < InheritedResources::Base
  before_action :require_user
	def new
		@game = Game.new
  end

  def index
    @games = Game.joins(game_round: :league_season).where('league_seasons.league_id = ? AND league_seasons.season_id = ?', League.find(params[:league_id]), Season.current.first)
  end

  def create
  	@game = Game.new(game_params)
    if @game.save
      flash[:success] = "Added game"
      redirect_to games_path
    else
      flash[:error] = "There was a problem adding that game."
      render action: :new
    end
	end

  private
  def game_params
    params.require(:game).permit(:home_team_id, :away_team_id, :game_week_id)
  end
end
