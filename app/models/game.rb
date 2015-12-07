class Game < ActiveRecord::Base
	belongs_to :home_team, :class_name => 'Team', :foreign_key => 'home_team_id'
 	belongs_to :away_team, :class_name => 'Team', :foreign_key => 'away_team_id'
 	belongs_to :game_week
 	validates :home_team, :away_team, :game_week, presence: true
 	validate :teams_in_same_league, on: :create
 	validate :teams_not_the_same, on: :create
 	validate :team_not_playing_twice_in_same_gameweek, on: :create

 	def match_up
 		"#{home_team.title} vs #{away_team.title}"
 	end

 	private
 	def teams_in_same_league
 		errors.add(:base, "Teams not in same league.") unless home_team.league === away_team.league
 	end

 	def teams_not_the_same
 		errors.add(:base, "A team cannot play itself.") unless home_team != away_team
 	end

 	def team_not_playing_twice_in_same_gameweek
 		home_team_games = Game.where('game_week_id=? AND (home_team_id=? OR away_team_id=?)', game_week.id, home_team.id, home_team.id)
 		away_team_games = Game.where('game_week_id=? AND (home_team_id=? OR away_team_id=?)', game_week.id, away_team.id, away_team.id)
 		errors.add(:base, "One of those teams already has a game in this game week.") unless home_team_games.count === 0 && away_team_games.count === 0
 	end
end
