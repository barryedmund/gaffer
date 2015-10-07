class Team < ActiveRecord::Base
	belongs_to :user
	belongs_to :league
	has_many :team_players
	validates :title, presence: true
	validates :title, length: { minimum: 3}
	validates :league_id, presence: true
	validate :team_count_within_limit, :on => :create

 	def team_count_within_limit
    	if self.league.teams(:reload).size >= 20
      		errors.add(:base, "Exceeded Team limit")
    	end
  	end
end
