class TeamAchievementsController < ApplicationController
  before_action :require_user

  def index
    @league = League.find_by_id(params[:league_id])
    @league_achievements = TeamAchievement.joins(:league_season).where('league_seasons.league_id = ?', params[:league_id])
    @team_achievements = TeamAchievement.joins(:team).where('teams.id = ?', params[:team_id])
  end
end
