class Team < ActiveRecord::Base
	belongs_to :user
	belongs_to :league
	has_many :team_players, dependent: :destroy
	has_many :home_games, :class_name => 'Game', :foreign_key => 'home_game_id'
  has_many :away_games, :class_name => 'Game', :foreign_key => 'away_game_id'
  has_many :player_lineups, dependent: :destroy
  has_many :contracts
  has_one :stadium, dependent: :destroy
	validates :title, :league, presence: true
	validates :title, length: { minimum: 3}
	validate :squad_positions_are_logical, :on => :update
	validates_associated :league, :message => "Too many teams."
	validates_uniqueness_of :league_id, scope: :user_id
	after_initialize :init
  accepts_nested_attributes_for :stadium, :allow_destroy => :true

  def init
    self.cash_balance_cents ||= 0
  end

	def squad_positions_are_logical
		count_of_goalies = self.team_players.joins(:squad_position).where("short_name LIKE 'GK'").count
    count_of_outfield_players = self.team_players.joins(:squad_position).where("short_name NOT LIKE 'GK' AND short_name NOT LIKE 'SUB'").count
    if (count_of_goalies > 1) || (count_of_outfield_players > 10)
    	errors.add(:base, "A team can only have 1 GK and 10 outfield players")
    end
	end

	def get_squad_position_whitelist
		first_team_squad_position_whitelist = SquadPosition.where(:id => nil)
		count_of_goalies = self.team_players.joins(:squad_position).where("short_name LIKE 'GK'").count
    if count_of_goalies == 0
    	first_team_squad_position_whitelist << SquadPosition.where("short_name LIKE 'GK'").first
    end
		count_of_outfield_players = self.team_players.joins(:squad_position).where("short_name NOT LIKE 'GK' AND short_name NOT LIKE 'SUB'").count
		if count_of_outfield_players < 10
			SquadPosition.where("short_name NOT LIKE 'GK' AND short_name NOT LIKE 'SUB'").each do |sp|
		    	first_team_squad_position_whitelist << sp
		    end
		end
		return first_team_squad_position_whitelist
	end

  def get_weekly_total_of_unsigned_contracts
    if contracts.where('signed = ?', false).count > 0
      contracts.where('signed = ?', false).sum(:weekly_salary_cents)
    else
      0
    end
  end

  def get_season_total_of_unsigned_contracts
    game_weeks_per_season = league.competition.game_weeks_per_season
    if contracts.where('signed = ?', false).count > 0
      contracts.where('signed = ?', false).sum(:weekly_salary_cents) * game_weeks_per_season
    else
      0
    end
  end

  def get_weekly_total_of_signed_contracts
    if contracts.where('signed = ?', true).count > 0
      contracts.where('signed = ?', true).sum(:weekly_salary_cents)
    else
      0
    end
  end

  def get_season_total_of_signed_contracts
    game_weeks_per_season = league.competition.game_weeks_per_season
    if contracts.where('signed = ?', true).count > 0
      contracts.where('signed = ?', true).sum(:weekly_salary_cents) * game_weeks_per_season
    else
      0
    end
  end

  def get_season_remaining_of_signed_contracts
    if league.current_league_season
      number_of_game_weeks = GameWeek.where(season_id: league.current_league_season.season.id, finished: false).count
    else
      number_of_game_weeks = league.competition.game_weeks_per_season
    end
     number_of_game_weeks * get_weekly_total_of_signed_contracts
  end

  def get_current_game
    league_current_league_season = league.current_league_season
    if league_current_league_season
      season = league_current_league_season.season
      game_week = season.get_current_game_week
      if game_week.present?
        game_week.games.where('home_team_id = :this_team OR away_team_id = :this_team', this_team: self.id).first
      end
    end
  end

  def abbreviated_title(cut_off = 13)
    working_title = title
    if working_title.length >= cut_off
      working_title = working_title[0, cut_off - 1] + '...'
    end
    working_title
  end

  def auto_transfer_list_squad
    puts "#{title} squad is being auto transfer listed..."
    team_players.each do |team_player|
      team_player.force_transfer_list
    end
    NewsItem.create(league: league, news_item_resource_type: 'Team', news_item_type: 'auto_transfer_list_squad', news_item_resource_id: id, body: "Team in financial difficulty")
  end

  def transfer_listed_players
     TeamPlayer.where('team_id = ? AND transfer_minimum_bid IS NOT NULL', self.id)
  end

  def has_team_players_involuntarily_listed
    transfer_listed_players.where(is_voluntary_transfer: false).count > 0 ? true : false
  end

  def should_be_back_in_the_black
    has_team_players_involuntarily_listed && cash_balance_cents > 0 ? true : false
  end

  def delist_involuntarily_listed_team_players
    team_players.each { |team_player| team_player.reset_transfer_attributes }
    NewsItem.create(league: league, news_item_resource_type: 'Team', news_item_type: 'delist_squad', news_item_resource_id: id, body: "Team out of financial difficulty")
  end

  def add_cash(cash_amount)
    update_attributes(cash_balance_cents: (cash_balance_cents + cash_amount))
  end

  def squad_value
    players_on_this_team = Player.where(available: true).where(id: (Player.joins(team_players: :team).where('teams.id = ?', self.id) ).map(&:id))
    players_on_this_team.to_a.sum { |player| player.player_value }
  end

  def squad_size
    team_players.count
  end

  def average_team_player_value
    squad_size > 0 ? (squad_value / squad_size) : 0
  end

  def total_weekly_wage_bill
    contracts.where('signed = ?', true).count > 0 ? (contracts.where('signed = ?', true).sum(:weekly_salary_cents)).round : 0
  end

  def average_weekly_wage_bill
    contracts.where('signed = ?', true).count > 0 && squad_size > 0 ? (contracts.where('signed = ?', true).sum(:weekly_salary_cents) / squad_size).round : 0
  end

  def galacticos
    team_players.sort_by{ |team_player| team_player.player.player_value }.last(11)
  end

  def galacticos_names
    galacticos.collect(&:last_name).join(', ')
  end

  def galacticos_value
    galacticos.to_a.sum { |team_player| team_player.player.player_value }
  end

  def most_valuable_available_sub_at_position(long_position)
    available_subs_at_position = team_players.joins(:squad_position, :player).where('squad_positions.short_name = ? AND team_players.first_team = ? AND players.news = ? AND players.playing_position = ?', 'SUB', false, '', long_position)
    if available_subs_at_position
      available_subs_at_position.sort_by{ |team_player| team_player.player.player_value }.last
    end
  end

  def number_of_game_weeks_played_this_season
    current_season.game_weeks.where(finished: true).count
  end

  def game_week_ago(number_of_game_weeks_ago)
    current_season.game_weeks.where(finished: true).order(starts_at: :desc).limit(number_of_game_weeks_ago).last
  end

  def current_season
    league.current_league_season.season
  end

  def is_zombie_team
    last_updated_team_player = team_players.order(:updated_at).last
    cut_off_game_week = game_week_ago(3)
    puts "last_updated_team_player: #{last_updated_team_player.inspect}"
    puts "cut_off_game_week: #{cut_off_game_week.inspect}"
    if last_updated_team_player && cut_off_game_week
      last_updated_team_player.updated_at < cut_off_game_week.starts_at
    else
      false
    end
  end

  def has_full_starting_team
    num_of_first_team_players = team_players.joins(:squad_position).where('squad_positions.short_name != ? AND team_players.first_team = ?', 'SUB', true).count
    num_of_first_team_players == 11
  end

  def has_subs_available
    num_of_available_subs = team_players.joins(:squad_position, :player).where('squad_positions.short_name = ? AND team_players.first_team = ? AND players.news = ?', 'SUB', false, '').count
    num_of_available_subs > 0
  end

  def is_eligible_for_robo_first_team_additions
    is_zombie_team && !has_full_starting_team && has_subs_available
  end

  def number_of_first_team_players_at_position(short_position)
    team_players.joins(:squad_position).where('squad_positions.short_name = ? AND team_players.first_team = ?', short_position, true).count
  end

  def has_sub_at_position(long_position)
    team_players.joins(:squad_position, :player).where('squad_positions.short_name = ? AND team_players.first_team = ? AND players.playing_position = ? AND players.news = ?', 'SUB', false, long_position, '').count > 0
  end

  def sub_to_move_to_first_team
    if is_eligible_for_robo_first_team_additions
      num_first_team_gk = number_of_first_team_players_at_position('GK')
      num_first_team_df = number_of_first_team_players_at_position('DF')
      num_first_team_md = number_of_first_team_players_at_position('MD')
      num_first_team_fw = number_of_first_team_players_at_position('FW')
      num_first_team_outfield = [num_first_team_df, num_first_team_md, num_first_team_fw]
      formation = "#{num_first_team_gk}-#{num_first_team_df}-#{num_first_team_md}-#{num_first_team_fw} (subs: #{has_subs_available})"

      player_has_not_been_added = true
      if player_has_not_been_added && num_first_team_gk < 1 && has_sub_at_position('Goalkeeper')
        player_has_not_been_added = false
        team_player_to_add = most_valuable_available_sub_at_position('Goalkeeper')
        team_player_to_add.update_attributes(first_team: true, squad_position: SquadPosition.find_by(id: team_player_to_add.get_squad_position_from_players_playing_position))
        "Add GK (#{team_player_to_add.full_name})" + formation
      end
      if player_has_not_been_added && num_first_team_df == num_first_team_outfield.min && has_sub_at_position('Defender')
        player_has_not_been_added = false
        team_player_to_add = most_valuable_available_sub_at_position('Defender')
        team_player_to_add.update_attributes(first_team: true, squad_position: SquadPosition.find_by(id: team_player_to_add.get_squad_position_from_players_playing_position))
        "Add DF (#{team_player_to_add.full_name})" + formation
      end
      if player_has_not_been_added && num_first_team_md == num_first_team_outfield.min && has_sub_at_position('Midfielder')
        player_has_not_been_added = false
        team_player_to_add = most_valuable_available_sub_at_position('Midfielder')
        team_player_to_add.update_attributes(first_team: true, squad_position: SquadPosition.find_by(id: team_player_to_add.get_squad_position_from_players_playing_position))
        "Add MD (#{team_player_to_add.full_name})" + formation
      end
      if player_has_not_been_added && num_first_team_fw == num_first_team_outfield.min && has_sub_at_position('Forward')
        player_has_not_been_added = false
        team_player_to_add = most_valuable_available_sub_at_position('Forward')
        team_player_to_add.update_attributes(first_team: true, squad_position: SquadPosition.find_by(id: team_player_to_add.get_squad_position_from_players_playing_position))
        "Add FW (#{team_player_to_add.full_name})" + formation
      end
    else
      'not eligible'
    end
  end
end
