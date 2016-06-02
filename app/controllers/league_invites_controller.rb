class LeagueInvitesController < ApplicationController

  def new
    @league_invite = LeagueInvite.new
  end

  def create
    @league_invite = LeagueInvite.new(league_id: params[:league_id], email: params[:league_invite][:email])
    if @league_invite.save
      flash[:success] = "Added"
      redirect_to league_league_invites_path(params[:league_id])
    else
      flash[:error] = "There was a problem adding that."
      render action: :new
    end
  end

  def index
    @league_invites = LeagueInvite.where(league_id: params[:league_id])
  end

  private
  def league_invite_params
    params.require(:league_invite).permit(:league_id, league_invite: :email)
  end
end
