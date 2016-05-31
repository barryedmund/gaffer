class LeagueInvitesController < ApplicationController

  def new
    @league_invite = LeagueInvite.new
  end

  def create
    @league_invite = LeagueInvite.new(league_id: params[:league_id], email: params[:email])
    if @league_invite.save
      flash[:success] = "Added"
      redirect_to league_path(@league_invite.league_id)
    else
      flash[:error] = "There was a problem adding that."
      redirect_to league_path(@league_invite.league_id)
    end
  end

  def index
    @league_invites = LeagueInvite.where(league_id: params[:league_id])
  end

  private
  def league_invite_params
    params.require(:league_invite).permit(:league_id, :email)
  end
end
