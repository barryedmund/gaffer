class PlayerGameWeeksController < ApplicationController
	before_action :require_user
	before_action :set_game_week
	before_action :set_player

	def new
		@player_game_week = PlayerGameWeek.new
	end

	def create
		@player_game_week = PlayerGameWeek.new(player_game_week_params)
	    if @player_game_week.save
	    	flash[:success] = "Added player game week"
	    	redirect_to leagues_path
  		else
  			flash[:error] = "There was a problem adding that player game week."
  			redirect_to leagues_path
	    end
	end

	private
	def set_player
  		@player = Player.find(params[:player_game_week][:player_id])
	end

	def set_game_week
  		@game_week = GameWeek.find(params[:player_game_week][:game_week_id])
	end

	def player_game_week_params
  		params.require(:player_game_week).permit(:player_id, :game_week_id)
	end
end
