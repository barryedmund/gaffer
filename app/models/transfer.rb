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

  def complete_transfer
    self.transfer_items.each do |transfer_item|
      if transfer_item.transfer_item_type === "Cash"
        transfer_item.sending_team.decrement!(:cash_balance_cents, transfer_item.cash_cents)
        transfer_item.receiving_team.increment!(:cash_balance_cents, transfer_item.cash_cents)
      elsif transfer_item.transfer_item_type === "Player"
        transfer_item.team_player.update_attributes(:team => transfer_item.receiving_team, :first_team => false, :squad_position => SquadPosition.find_by(:short_name => 'SUB'))
        Contract.where(team_player: transfer_item.team_player).first.update_attributes(team: transfer_item.receiving_team)
      end
    end
  end

  def current_user_involved?(current_user)
    (current_user === primary_team.user) ? true : (current_user === secondary_team.user) ? true : false
  end

 	private
 	def teams_in_same_league
 		errors.add(:base, "Teams not in same league.") unless primary_team.league === secondary_team.league
 	end

 	def teams_not_the_same
 		errors.add(:base, "A team cannot initiate a transfer with itself.") unless primary_team != secondary_team
 	end
end
