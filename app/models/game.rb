class Game < ActiveRecord::Base
	belongs_to :home_team, :class_name => 'Team', :foreign_key => 'home_team_id'
 	belongs_to :away_team, :class_name => 'Team', :foreign_key => 'away_team_id'
 	belongs_to :game_week
 	belongs_to :game_round
 	validates :home_team, :away_team, :game_week, :game_round, presence: true
 	validate :teams_in_same_league, :teams_not_the_same, :team_not_playing_twice_in_same_gameweek, on: :create
 	validates_uniqueness_of :game_round, scope: [:home_team, :away_team]

	def self.unfinished_games_of_team(team)
			Game.where(is_complete: false, home_team: team)
	end

 	def match_up
 		"#{home_team.title} - #{away_team.title}"
 	end

 	def get_league
 		game_round.league_season.league
 	end

	def present_live_score
		unless home_team_score.blank? && away_team_score.blank?
			"#{home_team_score} : #{away_team_score}"
		else
			"0 : 0"
		end
	end

  def get_live_score
    home_lineup = get_team_lineup(home_team)
    away_lineup = get_team_lineup(away_team)

    home_team_attack = get_total_attacking_contribution(home_lineup)
    away_team_attack = get_total_attacking_contribution(away_lineup)

    home_team_defence = get_clean_sheet_minutes(home_lineup)
    away_team_defence = get_clean_sheet_minutes(away_lineup)

    home_team_score = (home_team_attack * (1 - away_team_defence/990)).round
    away_team_score = (away_team_attack * (1 - home_team_defence/990)).round
		[home_team_score, away_team_score]
  end

 	def calculate_score
 		if game_week.finished
 			if !is_complete
				live_score = get_live_score
	 			self.update(home_team_score: live_score[0])
	 			self.update(away_team_score: live_score[1])
				self.update(is_complete: true)

        NewsItem.create(league: get_league, news_item_resource_type: 'Game', news_item_resource_id: id, body: get_score_description)
	 		end
		elsif game_week.in_play?
			live_score = get_live_score
			self.update(home_team_score: live_score[0])
			self.update(away_team_score: live_score[1])
		end
	end

 	def get_score
 		if is_complete
 			"#{home_team_score} : #{away_team_score}"
 		else
 			"- : -"
 		end
 	end

  def get_total_attacking_contribution(lineups)
    total_attacking_contribution = 0
    if lineups.count > 0
      lineups.each do |lineup|
        total_attacking_contribution += lineup.get_attacking_contribution
      end
    end
    total_attacking_contribution
  end

  def get_clean_sheet_minutes(lineups)
    total_defensive_contribution = 0
    if lineups.count > 0
      lineups.each do |lineup|
        total_defensive_contribution += lineup.get_defensive_contribution
      end
    end
    total_defensive_contribution
  end

  def get_score_description
    if is_complete
      winner = home_team_score == away_team_score ? false : true
      if winner
        winning_team = home_team_score > away_team_score ? home_team : away_team
        losing_team = home_team_score < away_team_score ? home_team : away_team
        scraped = (home_team_score - away_team_score).abs < 2 ? true : false
        hammered = (home_team_score - away_team_score).abs > 2 ? true : false
        if scraped
          "#{losing_team.user.first_name_camel_cased} narrowly defeated by #{winning_team.user.first_name_camel_cased}"
        elsif hammered
          "#{winning_team.user.first_name_camel_cased} hammered #{losing_team.user.first_name_camel_cased}"
        else
          "#{winning_team.user.first_name_camel_cased} easily beats #{losing_team.user.first_name_camel_cased}"
        end
      else
        if home_team_score == 0 && away_team_score == 0
          "#{home_team.user.first_name_camel_cased} and #{away_team.user.first_name_camel_cased} involved in bore draw"
        elsif (home_team_score + away_team_score > 3)
          "#{home_team.user.first_name_camel_cased} and #{away_team.user.first_name_camel_cased} tussle in exciting draw"
        else
          "#{home_team.user.first_name_camel_cased} drew with #{away_team.user.first_name_camel_cased}"
        end
      end
    end
  end

  def get_team_lineup_including_yet_to_play(team)
    # All player_lineups on this week and of players who are in the first team
    home_team_lineups = team.player_lineups.joins(:player_game_week, :squad_position).where('game_week_id = ? AND squad_positions.short_name != ?', game_week.id, 'SUB')
    # All team players on this team
    all_team_players = Player.where(id: team.team_players.where('team_players.first_team = ?', true).pluck('team_players.player_id'))
    # All players who already have a player_game_week for this game_week
    played_players = Player.where(id: (home_team_lineups.joins(player_game_week: :player).pluck('player_game_weeks.player_id')))
    # Players who are in the first team, but who don't yet have a game week for this week
    # ISSUE: Some players don't have a gameweek, but the gameweek has passed, e.g., late signings
    other_first_team_players = Player.where(id: (all_team_players - played_players).map(&:id))
    other_first_team_players_wth_game_week = other_first_team_players.joins(:player_game_weeks).where('player_game_weeks.game_week_id = ?', game_week.id)
    other_first_team_players_yet_to_play = Player.where(id: (other_first_team_players - other_first_team_players_wth_game_week).map(&:id))

    if game_week.finished?
      Player.where(id: (played_players).map(&:id)).sort_by{ |p| p.sort_val }
    else
      Player.where(id: (played_players + other_first_team_players_yet_to_play).map(&:id)).sort_by{ |p| p.sort_val }
    end
  end

  def is_finished
    (game_week.finished && is_complete) ? true : false
  end

 	private
  def get_team_lineup(team)
    team.player_lineups.joins(:player_game_week, :squad_position).where('player_game_weeks.game_week_id = ? AND squad_positions.short_name != ?', game_week.id, 'SUB')
  end

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
