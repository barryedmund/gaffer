class Transfer < ActiveRecord::Base
	belongs_to :primary_team, :class_name => 'Team', :foreign_key => 'primary_team_id'
 	belongs_to :secondary_team, :class_name => 'Team', :foreign_key => 'secondary_team_id'
  has_many :transfer_items, dependent: :destroy
 	validates :primary_team, :secondary_team, presence: true
 	validates :primary_team_accepted, :secondary_team_accepted, inclusion: { in: [true, false] }
 	validate :teams_in_same_league, :teams_not_the_same, on: :create
  accepts_nested_attributes_for :transfer_items

  def self.incomplete_transfers
    self.where('transfers.primary_team_accepted = :accepted_value OR transfers.secondary_team_accepted = :accepted_value', {accepted_value: false})
  end

  def self.incomplete_transfers_with_team_involved(team)
    incomplete_transfers.where('transfers.primary_team_id = :team_value OR transfers.secondary_team_id = :team_value', {team_value: team.id})
  end

  def self.incomplete_transfer_listings_due
    transfers = incomplete_transfers.select { |transfer| transfer.is_a_transfer_listing && (transfer.transfer_listing_completes_at < Time.now) }
    transfers.map{|i| i.id}
    Transfer.where(id: transfers)
  end

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
    self.update_attributes(primary_team_accepted: false, secondary_team_accepted: false)
  end

  def complete_transfer
    self.transfer_items.each do |transfer_item|
      if transfer_item.transfer_item_type === "Cash"
        transfer_item.sending_team.decrement!(:cash_balance_cents, transfer_item.cash_cents)
        transfer_item.receiving_team.increment!(:cash_balance_cents, transfer_item.cash_cents)
      elsif transfer_item.transfer_item_type === "Player"
        contract = transfer_item.team_player.current_contract
        contract.update_attributes!(signed: false)
        contract.update_attributes!(team: transfer_item.receiving_team, signed: true)
        transfer_item.team_player.update_attributes(team: transfer_item.receiving_team, first_team: false, squad_position: SquadPosition.find_by(:short_name => 'SUB'))
        TransferItem.where(transfer_item_type: "Player", team_player: transfer_item.team_player).where.not(id: transfer_item.id).each do |other_transfer_item|
          if !other_transfer_item.transfer.transfer_completed?
            other_transfer_item.transfer.reset_teams_transfer_status
            other_transfer_item.destroy
          end
        end
      end
    end
  end

  def current_user_involved?(current_user)
    (current_user === primary_team.user) ? true : (current_user === secondary_team.user) ? true : false
  end

  def get_cash_transfer_item
    transfer_items.where(transfer_item_type: 'Cash').first
  end

  def get_player_transfer_item
    transfer_items.where(transfer_item_type: 'Player').first
  end

  def get_team_player_involved
    get_player_transfer_item.get_team_player_in_transfer
  end

  def get_other_team_involved(team)
    primary_team == team ? secondary_team : primary_team
  end

  def is_a_transfer_listing
    get_team_player_involved.transfer_listed?
  end

  def transfer_listing_completes_at
    get_team_player_involved.transfer_completes_at
  end

 	private
 	def teams_in_same_league
 		errors.add(:base, "Teams not in same league.") unless primary_team.league === secondary_team.league
 	end

 	def teams_not_the_same
 		errors.add(:base, "A team cannot initiate a transfer with itself.") unless primary_team != secondary_team
 	end
end
