class League < ActiveRecord::Base
	has_many :teams, dependent: :destroy
	has_many :league_seasons, dependent: :destroy
	belongs_to :user
	belongs_to :competition
	validates :user_id, :competition, presence: true
	validates_each :teams do |league, attr, value|
   	league.errors.add attr, "Too many teams for league" if league.teams.size >= 20
	end

	def has_team_owned_by?(user)
		self.teams.where('user_id = ?', user.id).any?
	end

	def current_league_season
		league_seasons.each do |ls|
			if ls.season == Season.current
				return ls
			end
		end
	end

	def get_standings
		standings = teams.collect do |team|
			{
				:team_record => team,
				:games_played => 0,
				:games_won => 0,
			  :games_drawn => 0,
			  :games_lost => 0,
			  :goals_scored => 0,
			  :goals_conceded => 0,
			  :goal_difference => 0,
			  :points => 0
			}
		end
		
		league_games = self.get_games

		# Get games that have been played in the game_weeks that are in the current season
		# Get all played games from game_weeks that are in the current league_season
		
		league_games.joins(:game_week).where('game_weeks.league_season_id = ?', current_league_season).where.not('home_team_score' => nil, 'away_team_score' => nil).each do |game|
			current_home_team = standings.find do |standing|
				standing[:team_record] == game.home_team
			end
			current_away_team = standings.find do |standing|
				standing[:team_record] == game.away_team
			end
			current_home_team[:games_played] += 1
			current_home_team[:goals_scored] += game.home_team_score
			current_home_team[:goals_conceded] += game.away_team_score
			current_home_team[:goal_difference] = current_home_team[:goals_scored] - current_home_team[:goals_conceded]

			current_away_team[:games_played] += 1
			current_away_team[:goals_scored] += game.away_team_score
			current_away_team[:goals_conceded] += game.home_team_score
			current_away_team[:goal_difference] = current_away_team[:goals_scored] - current_away_team[:goals_conceded]

			if game.home_team_score == game.away_team_score
				current_home_team[:games_drawn] += 1
				current_away_team[:games_drawn] += 1
				current_home_team[:points] += 1
				current_away_team[:points] += 1
			elsif game.home_team_score > game.away_team_score
				current_home_team[:games_won] += 1
				current_away_team[:games_lost] += 1
				current_home_team[:points] += 3
			else
				current_home_team[:games_lost] += 1
				current_away_team[:games_won] += 1
				current_away_team[:points] += 3
			end
		end
		standings.sort_by! { |k| [k[:points], k[:goal_difference], k[:goals_scored]] }.reverse
	end

	def get_games
		# Games >> GameWeeks >> LeagueSeason >> League
		Game.joins(game_week: {league_season: :league}).where(leagues: {id: id}).all
	end
end
