class Game < ActiveRecord::Base
	belongs_to :home_team, :class_name => 'Team', :foreign_key => 'home_team_id'
 	belongs_to :away_team, :class_name => 'Team', :foreign_key => 'away_team_id'
 	belongs_to :game_week
 	belongs_to :game_round
 	validates :home_team, :away_team, :game_week, :game_round, presence: true
 	validate :teams_in_same_league, :teams_not_the_same, :team_not_playing_twice_in_same_gameweek, on: :create
 	validates_uniqueness_of :game_round, scope: [:home_team, :away_team]

 	def match_up
 		"#{home_team.title} vs #{away_team.title}"
 	end

 	def get_league
 		game_week.league_season.league
 	end

 	def calculate_score
 		if game_week.ends_at.past?
 			if (home_team_score.blank? || away_team_score.blank?)
	 			home_score = ((home_team.player_lineups.joins(:player_game_week, :squad_position).where('player_game_weeks.game_week_id = ? AND squad_positions.short_name != ?', game_week.id, 'SUB').sum('player_game_weeks.minutes_played')) / 180).round
	 			away_score = ((away_team.player_lineups.joins(:player_game_week, :squad_position).where('player_game_weeks.game_week_id = ? AND squad_positions.short_name != ?', game_week.id, 'SUB').sum('player_game_weeks.minutes_played')) / 180).round
	 			self.update(home_team_score: home_score)
	 			self.update(away_team_score: away_score)
	 		end
 		end
	end

 	def get_score
 		if home_team_score.present? && away_team_score.present?
 			"#{home_team_score} : #{away_team_score}"
 		else
 			"- : -"
 		end
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
