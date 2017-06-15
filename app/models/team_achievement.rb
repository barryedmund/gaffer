class TeamAchievement < ActiveRecord::Base
  belongs_to :team
  belongs_to :league_season
  belongs_to :achievement

  validates :league_season, :achievement, presence: true
end
