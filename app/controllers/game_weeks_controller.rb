class GameWeeksController < InheritedResources::Base
	before_action :set_league
	before_action :set_team
	before_action :set_player

	def index
		@game_weeks = GameWeek.where(:player_id => params[:player_id])
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

