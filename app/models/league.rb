class League < ActiveRecord::Base
	has_many :teams, dependent: :destroy
	has_many :league_seasons, dependent: :destroy
	has_many :news_items
	has_many :league_invites
	belongs_to :user
	belongs_to :competition
	validates :user_id, :competition, :name, presence: true
	validates_each :teams do |league, attr, value|
   	league.errors.add attr, "Too many teams for league" if league.teams.size >= 20
	end

	def self.active_leagues
		League.joins(teams: :user).where('users.last_seen_at > ?', 3.weeks.ago).uniq
	end

	def has_team_owned_by?(user)
		self.teams.where('user_id = ?', user.id).any?
	end

	def is_owned_by_this_user?(this_user)
		user == this_user ? true : false
	end

	def current_league_season
		league_seasons.joins(:season).where("seasons.starts_at <= :date AND seasons.ends_at >= :date", date: Date.today).first
	end

	def current_game_week
		current_league_season.season.get_current_game_week
	end

	def current_game_week_games
		if current_league_season
			league_games = get_games
			league_games.where(is_complete: false, game_week: current_game_week)
		end
	end

	def league_user_name(this_user)
		if is_owned_by_this_user?(this_user)
			"you"
		else
			user.first_name_camel_cased
		end
	end

	def get_standings
		if current_league_season
			participating_teams = current_league_season.participating_teams
		else
			participating_teams = teams.where(deleted_at: nil)
		end
		standings = participating_teams.collect do |team|
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
		league_games.joins(:game_round).where('game_rounds.league_season_id = ?', current_league_season).where('games.is_complete = ?', true).each do |game|
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
		Game.joins(game_round: {league_season: [:league, :season]}).where(leagues: {id: id}, seasons: {id: Season.current.first.id}).all
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

	def team_players
		TeamPlayer.joins(:team).where("teams.league_id = ?", self.id)
	end

	def sign_players_for_zombies
		puts ""
		puts self.name
		most_recently_finished_gameweek = GameWeek.get_most_recent_finished
		current_season = Season.current.first
		# Go through each team
		self.teams.where(deleted_at: nil).order("RANDOM()").each do |team|
			combined_players = team.get_players_with_contract_offers + team.get_players_in_existing_bids
			# Are they a zombie team and do they need a player?
			if team.is_zombie_team && what_to_sign = team.get_position_to_sign(combined_players)
				puts "#{team.title} (#{what_to_sign})"
				# Sort the player game weeks by value
				PlayerGameWeek.where("game_week_id = ? AND player_value IS NOT NULL", most_recently_finished_gameweek.id).joins(:player).where("players.news = ? AND players.available = ?", '', true).order("player_game_weeks.player_value DESC").each do |pgw|
					# If the player is the right position
					should_randomise = false
					if team.team_players.count < 6 && rand < 0.3
						should_randomise = true
					end
					player_plays = (pgw.player.percentage_of_minutes_played_this_season(current_season) >= 0.5) || (pgw.player.eligible_game_weeks_this_season(current_season) == 0)
					if pgw.player.playing_position == what_to_sign && player_plays && !should_randomise
						team_player = TeamPlayer.where(player: pgw.player).joins(:team).where('teams.league_id = ?', self.id).first
						# If the player belongs to a team
						if team_player
							is_transfer_listed = team_player.transfer_minimum_bid.present?
							# If the player is transfer listed
							if is_transfer_listed
								team_player_salary = team_player.current_contract.weekly_salary_cents
								is_transfer_price_reasonable = team_player.transfer_minimum_bid <= (pgw.player_value * 1.1)
								is_not_on_this_team = team_player.team != team
								is_reasonable_salary = team_player_salary <= (team.home_game_revenue * 0.1)
								is_fiscally_responsible = team.end_of_season_financial_position(team_player_salary, team_player.transfer_minimum_bid) > Rails.application.config.min_remaining_for_zombie_after_transfer_bid
								has_enough_cash = team_player.transfer_minimum_bid < team.cash_balance_cents
								has_existing_bid = team_player.has_active_transfer_bid_from_team(team)
								# If the finances match up
								if is_transfer_price_reasonable && is_not_on_this_team && is_reasonable_salary && is_fiscally_responsible && !has_existing_bid && has_enough_cash
									puts ">> Has #{team.cash_balance_cents}. Will bid on #{pgw.player.full_name} from #{team_player.team.title} for #{team_player.transfer_minimum_bid}. Will leave team with #{team.end_of_season_financial_position(team_player_salary, team_player.transfer_minimum_bid)} at the end of the season."
									Transfer.set_up_transfer(team, team_player, team_player.transfer_minimum_bid)
									break
								end
							end
						# If the player is a free agent
						else
							puts ">> Has #{team.cash_balance_cents}. Will sign #{pgw.player.full_name} for free. Will leave team with #{team.end_of_season_financial_position(25000)} at the end of the season."
							standard_ends_at = Rails.application.config.min_length_of_contract_days.days.from_now.strftime('%Y-%m-%d')
							standard_salary = Rails.application.config.min_weekly_salary_of_contract
							@contract_offer = Contract.new(team: team, player: pgw.player, starts_at: Date.today, ends_at: standard_ends_at, weekly_salary_cents: standard_salary)
							if @contract_offer.save
								NewsItem.create(league: team.league, news_item_resource_type: 'Contract', news_item_resource_id: @contract_offer.id, body: "#{@contract_offer.player.full_name(true,13)} offered contract")
							end
							break
						end
					end
				end
			end
		end
	end
end
