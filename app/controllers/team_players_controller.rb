class TeamPlayersController < ApplicationController
  before_action :require_user
  before_action :set_team
  before_action :set_team_player, only: [:show, :release, :update]

  def new
  	@team_player = @team.team_players.new
    @team_player.contracts.build
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
    if @team_player.first_team
      if @team_player.update_attributes(:first_team => false, :squad_position => SquadPosition.where(short_name: 'SUB').take)
        redirect_to league_team_path(@team_player.team.league, @team_player.team), notice: "Removed from first team."
      else
        flash[:error] = @team_player.errors.full_messages.to_sentence
        redirect_to league_team_path(@team_player.team.league, @team_player.team)
       end
    else
      if @team_player.update_attributes(:first_team => true, squad_position: SquadPosition.find_by(id: params[:team_player][:squad_position_id]))
        redirect_to league_team_path(@team_player.team.league, @team_player.team), notice: "Added to first team."
      else
        flash[:error] = @team_player.errors.full_messages.to_sentence
        redirect_to league_team_path(@team_player.team.league, @team_player.team)
      end
    end
  end

  def release
    player_for_news_item = @team_player.player
    league = @team.league
    @team.update_attributes(cash_balance_cents: (@team.cash_balance_cents - @team_player.current_contract.release_value))
    self.destroy
    NewsItem.create(league: league, news_item_resource_type: 'Player', news_item_resource_id: player_for_news_item.id, body: "Player released by #{@team.title}")
  end

  def update
    if @team_player.update(team_player_params)
      redirect_to league_team_team_player_path(@team_player.team.league, @team_player.team, @team_player), success: "#{@team_player.full_name} has been transfer listed."
    else
      flash[:error] = "#{@team_player.full_name} was not transfer listed."
      render :edit
    end
  end

  private
  def set_team
    @team = current_user.teams.find(params[:team_id])
  end

  def set_team_player
    @team_player = TeamPlayer.find(params[:id])
  end

  def team_player_params
  	params.require(:team_player).permit(:first_team, :team_id, :player_id, :is_voluntary_transfer, :transfer_minimum_bid, :transfer_completes_at, contracts_attributes: [:weekly_salary_cents, :team_id, :starts_at, :ends_at])
  end
end
