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

	def create_game_rounds
		number_of_teams = teams.count
		games_per_game_round = number_of_teams * (number_of_teams - 1)
		game_weeks_per_game_round = games_per_game_round / (number_of_teams / 2)
		game_rounds_per_season = (competition.game_weeks_per_season / game_weeks_per_game_round.to_f).ceil
		season = Season.current.where("competition_id = ?", competition.id).first
		(1..game_rounds_per_season).each do |i|
			game_rounds.create(:game_round_number => i, :league => self, :season => season)
		end
	end

	def create_games
		game_permutations = Team.where('league_id = ?', self.id).to_a.permutation(2).to_a.shuffle
		season = Season.current.where("competition_id = ?", competition.id).first
		ordered_game_weeks = season.game_weeks.order(:starts_at)
		ordered_game_rounds = game_rounds.order(:game_round_number)
		game_round_counter = 0
		games_per_game_round = teams.count * (teams.count - 1)
		games_per_game_week = teams.count / 2
		ordered_game_weeks.each do |game_week|
			if games.where("league_id = ? AND game_round_id = ?", self, ordered_game_rounds[game_round_counter].id).count == games_per_game_round
					game_round_counter += 1
			end
			game_permutations.each do |game_perm|
				game = games.new(:home_team => game_perm[0], :away_team => game_perm[1], :game_week => game_week, :game_round => ordered_game_rounds[game_round_counter])
				if game.valid?
					game.save!
					if games.where("league_id = ? AND game_week_id = ?", self, game_week.id).count >= games_per_game_week
						break
					end
				end
			end
		end
		if games.joins(:game_week).where("games.league_id = ? AND game_weeks.season_id = ?", self, season).count != (games_per_game_week * competition.game_weeks_per_season)
			games.joins(:game_week).where("games.league_id = ? AND game_weeks.season_id = ?", self, season).delete_all
			create_games
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

		league_games.joins(:game_week).where('game_weeks.season_id = ?', competition.seasons.current)
			.where.not('home_team_score' => nil, 'away_team_score' => nil).each do |game|
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
