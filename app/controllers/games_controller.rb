class GamesController < InheritedResources::Base

	def new
		@game = Game.new
  end

  def index
    @games = Game.where('league_id=?', League.find(params[:league_id]))
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
