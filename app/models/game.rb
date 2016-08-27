class Game < ActiveRecord::Base
	belongs_to :home_team, :class_name => 'Team', :foreign_key => 'home_team_id'
 	belongs_to :away_team, :class_name => 'Team', :foreign_key => 'away_team_id'
 	belongs_to :game_week
 	belongs_to :game_round
 	validates :home_team, :away_team, :game_week, :game_round, presence: true
 	validate :teams_in_same_league, :teams_not_the_same, :team_not_playing_twice_in_same_gameweek, on: :create
 	validates_uniqueness_of :game_round, scope: [:home_team, :away_team]

 	def match_up
 		"#{home_team.title} - #{away_team.title}"
 	end

 	def get_league
 		game_round.league_season.league
 	end

 	def calculate_score
 		if game_week.finished
 			if (home_team_score.blank? || away_team_score.blank?)

	 			home_lineup = home_team.player_lineups.joins(:player_game_week, :squad_position).where('player_game_weeks.game_week_id = ? AND squad_positions.short_name != ?', game_week.id, 'SUB')
        home_clean_sheet_minutes = 0
        home_goals_scored = 0
        home_lineup.each do |lineup|
          lineup_player_game_week = lineup.player_game_week
          lineup_player_squad_position = lineup.squad_position
          
          player_clean_sheet_minutes = lineup_player_game_week.minutes_played > 0 ? (lineup_player_game_week.minutes_played / (lineup_player_game_week.goals_conceded + 1)) : 0
          
          player_goals = lineup_player_game_week.goals
          
          if lineup_player_squad_position.short_name === 'GK'
            player_goals += lineup_player_game_week.assists.to_i * 0.5

          elsif lineup_player_squad_position.short_name === 'DF'
            player_goals += lineup_player_game_week.assists.to_i * 0.4

          elsif lineup_player_squad_position.short_name === 'MD'
            player_clean_sheet_minutes = player_clean_sheet_minutes / 2
            player_goals += lineup_player_game_week.assists.to_i * 0.3

          elsif lineup_player_squad_position.short_name === 'FW'
            player_clean_sheet_minutes = 0
            player_goals += lineup_player_game_week.assists.to_i * 0.2
            
          end
          
          home_clean_sheet_minutes += player_clean_sheet_minutes
          home_goals_scored += player_goals
        end

        away_lineup = away_team.player_lineups.joins(:player_game_week, :squad_position).where('player_game_weeks.game_week_id = ? AND squad_positions.short_name != ?', game_week.id, 'SUB')
        away_clean_sheet_minutes = 0
        away_goals_scored = 0
        away_lineup.each do |lineup|
          lineup_player_game_week = lineup.player_game_week
          lineup_player_squad_position = lineup.squad_position
          player_clean_sheet_minutes = lineup_player_game_week.minutes_played > 0 ? (lineup_player_game_week.minutes_played / (lineup_player_game_week.goals_conceded + 1)) : 0
          player_goals = lineup_player_game_week.goals
          if lineup_player_squad_position.short_name === 'MD'
            player_clean_sheet_minutes = player_clean_sheet_minutes / 2
          elsif lineup_player_squad_position.short_name === 'FW'
            player_clean_sheet_minutes = 0
          end
          away_clean_sheet_minutes += player_clean_sheet_minutes
          away_goals_scored += player_goals
        end

        home_clean_sheet_performance = (home_clean_sheet_minutes / 9.9) / 100
        away_clean_sheet_performance = (away_clean_sheet_minutes / 9.9) / 100
        home_score = (home_goals_scored * (1 - away_clean_sheet_performance)).round
        away_score = (away_goals_scored * (1 - home_clean_sheet_performance)).round
	 			self.update(home_team_score: home_score)
	 			self.update(away_team_score: away_score)
	 		end
 		end
	end

  def calculate_score_for_team(team)

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
