class League < ActiveRecord::Base
	has_many :teams, dependent: :destroy
	has_many :games, dependent: :destroy
	has_many :game_rounds, dependent: :destroy
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
		teams.order(:title)
	end

end
