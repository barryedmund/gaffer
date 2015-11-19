class League < ActiveRecord::Base
	has_many :teams, dependent: :destroy
	belongs_to :user
	validates :user_id, presence: true
	validates_each :teams do |league, attr, value|
   		league.errors.add attr, "Too many teams for league" if league.teams.size >= 20
  	end

	def has_team_owned_by?(user)
		self.teams.where('user_id = ?', user.id).any?
	end
end
