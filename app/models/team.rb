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
    season = league.current_league_season.first.season
    GameWeek.where(season_id: season.id, finished: false).count * get_weekly_total_of_signed_contracts
  end

  def get_current_game
    if league.current_league_season.first
      season = league.current_league_season.first.season
      game_week = season.get_current_game_week
      game_week.games.where('home_team_id = :this_team OR away_team_id = :this_team', this_team: self.id).first
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
  end
end
