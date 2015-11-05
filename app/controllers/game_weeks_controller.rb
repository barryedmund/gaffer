class GameWeeksController < InheritedResources::Base
	before_action :set_league
	before_action :set_team
	before_action :set_player

	def index
		@game_weeks = GameWeek.where(:player_id => params[:player_id])
	end

  def new
    @game_week = GameWeek.new
  end

  def create
    @game_week = GameWeek.new(game_week_params)
    respond_to do |format|
        if @game_week.save
          format.html { redirect_to @game_week, notice: 'GameWeek was successfully created.' }
        else
          format.html { render :new }
        end
      end
  end

	private
	def set_league
  		@league = League.find(params[:league_id])
	end

	def set_team
  		@team = Team.find(params[:team_id])
	end

	def set_player
  		@player = Player.find(params[:player_id])
	end

	def game_week_params
  		params.require(:game_week).permit(:player_id)
	end
end

