class League < ActiveRecord::Base
	has_many :teams, dependent: :destroy
	has_many :league_seasons, dependent: :destroy
	has_many :news_items
	belongs_to :user
	belongs_to :competition
	validates :user_id, :competition, :name, presence: true
	validates_each :teams do |league, attr, value|
   	league.errors.add attr, "Too many teams for league" if league.teams.size >= 20
	end

	def has_team_owned_by?(user)
		self.teams.where('user_id = ?', user.id).any?
	end

	def is_owned_by_this_user?(this_user)
		user == this_user ? true : false
	end

	def current_league_season
		league_seasons.each do |ls|
			if ls.season == Season.current
				return ls
			end
		end
	end

	def current_game_week
		current_league_season.first.season.get_current_game_week
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
		league_games.joins(:game_round).where('game_rounds.league_season_id = ?', current_league_season).where.not('home_team_score' => nil, 'away_team_score' => nil).each do |game|
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
		Game.joins(game_round: {league_season: :league}).where(leagues: {id: id}).all
	end

	def next_game_week_deadline
		previous_game_week = competition.current_season.game_weeks.order(starts_at: :desc).where('ends_at < ?', Time.now).first
		next_game_week = competition.current_season.game_weeks.order(:starts_at).where('starts_at > ?', Time.now).first
		if previous_game_week
			if !previous_game_week.finished
				previous_game_week.starts_at
			else
				if next_game_week
					next_game_week.starts_at
				else
					"None upcoming"
				end
			end
		else
			if next_game_week
				next_game_week.starts_at
			else
				"None upcoming"
			end
		end
	end
end
