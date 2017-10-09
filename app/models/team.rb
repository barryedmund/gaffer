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

  def get_players_with_contract_offers
    contracts.where(signed: false).pluck(:player_id)
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
    if user.last_seen_at.blank?
      last_updated_team_player = team_players.order(:updated_at).last
      if last_updated_team_player
        user.update_attributes(last_seen_at: last_updated_team_player.updated_at)
      else
        user.update_attributes(last_seen_at: Time.now)
      end
    end
    
    cut_off_game_week = game_week_ago(3)
    if cut_off_game_week
      user.last_seen_at < cut_off_game_week.starts_at
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

  def number_of_subs_at_position(long_position)
    team_players.joins(:squad_position, :player).where('squad_positions.short_name = ? AND team_players.first_team = ? AND players.playing_position = ? AND players.news = ?', 'SUB', false, long_position, '').count
  end

  def has_sub_at_position(long_position)
    team_players.joins(:squad_position, :player).where('squad_positions.short_name = ? AND team_players.first_team = ? AND players.playing_position = ? AND players.news = ?', 'SUB', false, long_position, '').count > 0
  end

  def get_most_needed_position
    if is_eligible_for_robo_first_team_additions
      has_sub_gk = has_sub_at_position('Goalkeeper')
      num_first_team_gk = number_of_first_team_players_at_position('GK')
      first_team_outfield = [
        {pos: "Defender", has_sub: has_sub_at_position('Defender'), num_first_team: number_of_first_team_players_at_position('DF')},
        {pos: "Midfielder", has_sub: has_sub_at_position('Midfielder'), num_first_team: number_of_first_team_players_at_position('MD')},
        {pos: "Forward", has_sub: has_sub_at_position('Forward'), num_first_team: number_of_first_team_players_at_position('FW')}]
      if num_first_team_gk < 1 && has_sub_gk
        'Goalkeeper'
      elsif team_players.joins(:squad_position).where("short_name NOT LIKE 'GK' AND short_name NOT LIKE 'SUB'").count < 10
        positions_with_subs = first_team_outfield.select { |position| position[:has_sub] }
        positions_with_subs_with_fewest_first_team_players = positions_with_subs.min_by { |position| position[:num_first_team] }
        positions_with_subs_with_fewest_first_team_players[:pos]
      end
    end
  end

  def sub_to_move_to_first_team
    position_to_add = get_most_needed_position
    if position_to_add
      team_player_to_add = most_valuable_available_sub_at_position(position_to_add)
      if team_player_to_add
        team_player_to_add.update_attributes(first_team: true, squad_position: SquadPosition.find_by(id: team_player_to_add.get_squad_position_from_players_playing_position))
        puts "#{team_player_to_add.full_name} (#{team_player_to_add.player.playing_position})"
        true
      else
        false
      end
    else
      false
    end
  end

  def formation_with_subs
    "#{number_of_first_team_players_at_position('GK')} - #{number_of_first_team_players_at_position('DF')} - #{number_of_first_team_players_at_position('MD')} - #{number_of_first_team_players_at_position('FW')} (#{number_of_subs_at_position('Goalkeeper')} - #{number_of_subs_at_position('Defender')} - #{number_of_subs_at_position('Midfielder')} - #{number_of_subs_at_position('Forward')})"
  end

  def get_position_to_sign(player_ids_of_contract_offers = nil)
    players_with_contract_offers = Player.where('id IN (?)', player_ids_of_contract_offers)
    num_contract_offers_gk = players_with_contract_offers.where(playing_position: 'Goalkeeper').count
    num_contract_offers_df = players_with_contract_offers.where(playing_position: 'Defender').count
    num_contract_offers_md = players_with_contract_offers.where(playing_position: 'Midfielder').count
    num_contract_offers_fw = players_with_contract_offers.where(playing_position: 'Forward').count

    num_ft_gk = number_of_first_team_players_at_position('GK') + num_contract_offers_gk
    num_ft_df = number_of_first_team_players_at_position('DF') + num_contract_offers_df
    num_ft_md = number_of_first_team_players_at_position('MD') + num_contract_offers_md
    num_ft_fw = number_of_first_team_players_at_position('FW') + num_contract_offers_fw

    num_squad_gk = num_ft_gk + number_of_subs_at_position('Goalkeeper')
    num_squad_df = num_ft_df + number_of_subs_at_position('Defender')
    num_squad_md = num_ft_md + number_of_subs_at_position('Midfielder')
    num_squad_fw = num_ft_fw + number_of_subs_at_position('Forward')

    if !has_full_starting_team
      if num_ft_gk == 0
        'Goalkeeper'
      else
        first_team_outfield = [
        {pos: "Defender", num_first_team: num_ft_df},
        {pos: "Midfielder", num_first_team: num_ft_md},
        {pos: "Forward", num_first_team: num_ft_fw}]
        positions_with_fewest_first_team_players = first_team_outfield.min_by { |position| position[:num_first_team] }
        positions_with_fewest_first_team_players[:pos]
      end
    elsif num_squad_gk < 2
      'Goalkeeper'
    elsif num_squad_df < 6
      'Defender'
    elsif num_squad_md < 6
      'Midfielder'
    elsif num_squad_fw < 5
      'Forward'
    else
      false
    end
  end

  def get_active_transfers
    Transfer.where('(transfers.primary_team_id = :your_team OR transfers.secondary_team_id = :your_team) AND (transfers.primary_team_accepted = :not_accepted OR transfers.secondary_team_accepted = :not_accepted)', your_team: self.id, not_accepted: false)
  end
end
