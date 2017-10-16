class PlayersController < ApplicationController
	before_action :require_user
	before_action :set_player, only: [:show]

	def index
    @players = Player.where(available: true)
    @league = League.find_by_id(params[:league_id])
    puts "params[:is_transfer_listed]: #{params[:is_transfer_listed]}"
    if params[:search]
      @players = @players.search(params[:search].strip)
    end
    if params[:is_transfer_listed] && params[:is_transfer_listed] == 'true'
      @players = @players.joins(team_players: :team).where('teams.league_id = ? AND team_players.transfer_minimum_bid IS NOT NULL', @league.id)
    end
  end

	def new
		@player = Player.new
	end

	def create
		@player = Player.new(player_params)
		
		respond_to do |format|
      if @player.save
        format.html { redirect_to @player, notice: 'Player was successfully created.' }
      else
        format.html { render :new }
      end
    end
	end


  private
	def set_player
    @player = Player.find(params[:id])
  end

  def player_params
    params.require(:player).permit(:first_name, :last_name)
  end
end

