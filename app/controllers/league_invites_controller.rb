class LeagueInvitesController < ApplicationController

  def new
    @league_invite = LeagueInvite.new
  end

  def create
    @league_invite = LeagueInvite.new(league_invite_params)
    if @league_invite.save
      Notifier.league_invitation(@league_invite.email, @league_invite.league).deliver
      flash[:success] = "Invite sent"
      render action: :index
    else
      render action: :new
    end
  end

  def index
    @league_invites = LeagueInvite.where(league_id: params[:league_id])
  end

  def destroy
    @league_invite = LeagueInvite.find(params[:id])
    if @league_invite.present?
      @league_invite.destroy
    end
    render action: :index
  end

  private
  def league_invite_params
    params.require(:league_invite).permit(:league_id, :email)
  end
end
