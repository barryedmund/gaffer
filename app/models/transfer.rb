class Transfer < ActiveRecord::Base
	belongs_to :primary_team, :class_name => 'Team', :foreign_key => 'primary_team_id'
 	belongs_to :secondary_team, :class_name => 'Team', :foreign_key => 'secondary_team_id'
  has_many :transfer_items, dependent: :destroy
 	validates :primary_team, :secondary_team, presence: true
 	validates :primary_team_accepted, :secondary_team_accepted, inclusion: { in: [true, false] }
 	validate :teams_in_same_league, :teams_not_the_same, on: :create

  def transfer_completed?
    primary_team_accepted ? (secondary_team_accepted ? true : false) : false
  end

  def team_transfer_status(team)
    if team == primary_team
      primary_team_accepted ? 'accepted' : 'not accepted'
    elsif team == secondary_team
      secondary_team_accepted ? 'accepted' : 'not accepted'
    else
      nil
    end
  end

  def reset_teams_transfer_status
    self.update_attributes(:primary_team_accepted => false, :secondary_team_accepted => false)
  end

 	private
 	def teams_in_same_league
 		errors.add(:base, "Teams not in same league.") unless primary_team.league === secondary_team.league
 	end

 	def teams_not_the_same
 		errors.add(:base, "A team cannot initiate a transfer with itself.") unless primary_team != secondary_team
 	end
end
