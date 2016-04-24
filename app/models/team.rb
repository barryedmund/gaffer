class Team < ActiveRecord::Base
	belongs_to :user
	belongs_to :league
	has_many :team_players, dependent: :destroy
	has_many :home_games, :class_name => 'Game', :foreign_key => 'home_game_id'
  has_many :away_games, :class_name => 'Game', :foreign_key => 'away_game_id'
  has_many :player_lineups, dependent: :destroy
  has_many :contracts
	validates :title, :league, presence: true
	validates :title, length: { minimum: 3}
	validate :squad_positions_are_logical, :on => :update
	validates_associated :league, :message => "Too many teams."
	validates_uniqueness_of :league_id, scope: :user_id
	after_initialize :init

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
end
