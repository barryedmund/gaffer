class TeamPlayersController < ApplicationController
  before_action :require_user
  before_action :find_team_player

  def new
  	@team_player = @team.team_players.new
  end

  def create
  	@team_player = @team.team_players.new(team_player_params)
    @team_player.squad_position = SquadPosition.find_by short_name: 'SUB'
  	if @team_player.save
  		flash[:success] = "Added team player"
  		redirect_to league_team_path(@team_player.team.league, @team_player.team)
  	else
  		flash[:error] = "There was a problem adding that player."
  		render action: :new
  	end
  end

  def destroy
    @team_player = @team.team_players.find(params[:id])
    if @team_player.destroy
      flash[:success] = "Team player was removed successfully."
    else
      flash[:error] = "Team player was not removed successfully."
    end
    redirect_to league_team_path(@team_player.team.league, @team_player.team)
  end

  def update_first_team
    @team_player = @team.team_players.find(params[:id])
    if params[:team_player][:position_change_only] == true.to_s
      @team_player.update_attributes(:first_team => true, :squad_position => SquadPosition.where(id: params[:squad_position][:team_player]).take)
      redirect_to league_team_path(@team_player.team.league, @team_player.team), notice: "Position changed."
    else
      if @team_player.first_team
        @team_player.update_attributes(:first_team => false, :squad_position => SquadPosition.where(short_name: 'SUB').take)
        redirect_to league_team_path(@team_player.team.league, @team_player.team), notice: "Removed from first team."
      else
        @team_player.update_attributes(:first_team => true, :squad_position => SquadPosition.where(id: params[:squad_position][:team_player]).take)
        redirect_to league_team_path(@team_player.team.league, @team_player.team), notice: "Added to first team."
      end
    end
  end

  private
  def find_team_player
    @team = current_user.teams.find(params[:team_id])
  end

  def team_player_params
  	params.require(:team_player).permit(:first_team, :team_id, :player_id)
  end
end
