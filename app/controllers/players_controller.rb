class PlayersController < ApplicationController
	before_action :require_user
	before_action :set_player, only: [:show]

	def index
    	@players = Player.all
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

