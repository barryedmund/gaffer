class TeamPlayersController < ApplicationController
  def index
  	@team = Team.find(params[:team_id])
  end

  def new
  	@team = Team.find(params[:team_id])
  	@team_player = @team.team_players.new
  end

  def create
  	@team = Team.find(params[:team_id])
  	@team_player = @team.team_players.new(team_player_params)
  	if @team_player.save
  		flash[:success] = "Added team player"
  		redirect_to team_team_players_path
  	else
  		flash[:error] = "There was a problem adding that player."
  		render action: :new
  	end
  end

  private
  def team_player_params
  	params[:team_player]
  end
end
