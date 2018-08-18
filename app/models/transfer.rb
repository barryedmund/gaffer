class Transfer < ActiveRecord::Base
	belongs_to :primary_team, :class_name => 'Team', :foreign_key => 'primary_team_id'
 	belongs_to :secondary_team, :class_name => 'Team', :foreign_key => 'secondary_team_id'
  has_many :transfer_items, dependent: :destroy
 	validates :primary_team, :secondary_team, presence: true
 	validates :primary_team_accepted, :secondary_team_accepted, inclusion: { in: [true, false] }
 	validate :teams_in_same_league, :teams_not_the_same
  accepts_nested_attributes_for :transfer_items

  def self.incomplete_transfers
    self.where('transfers.primary_team_accepted = :accepted_value OR transfers.secondary_team_accepted = :accepted_value', {accepted_value: false})
  end

  def self.incomplete_transfers_with_team_involved(teams)
    team_ids = teams.pluck(:id)
    incomplete_transfers.where('transfers.primary_team_id IN (:team_value) OR transfers.secondary_team_id IN (:team_value)', {team_value: team_ids})
  end

  def self.set_up_transfer(team_making_offer, team_player, bid_amount)
    new_transfer = Transfer.create(primary_team: team_making_offer, secondary_team: team_player.team, primary_team_accepted: true, secondary_team_accepted: false)
    cash_transfer_item = TransferItem.create(transfer: new_transfer, sending_team: team_player.team, receiving_team: team_making_offer, transfer_item_type: 'Player', team_player: team_player)
    player_transfer_item = TransferItem.create(transfer: new_transfer, sending_team: team_making_offer, receiving_team: team_player.team, transfer_item_type: 'Cash', cash_cents: bid_amount)
    if new_transfer
      new_transfer.set_team_player_transfer_completes_at
      NewsItem.create(league: team_making_offer.league, news_item_resource_type: 'Transfer', news_item_resource_id: new_transfer.id, body: "Transfer initiated by #{new_transfer.primary_team.title}")
    end
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

  def complete_a_transfer_listing
    if is_auto_completing
      self.update_attributes(primary_team_accepted: true, secondary_team_accepted: true)
      complete_transfer
    end
  end

  def complete_transfer
    if transfer_completed?
      self.get_team_player_involved.active_transfers.where.not(id: self.id).each do |losing_transfer|
        losing_transfer.destroy
      end
      self.transfer_items.each do |transfer_item|
        receiver = transfer_item.receiving_team
        sender = transfer_item.sending_team
        if transfer_item.transfer_item_type === "Cash"
          sender.decrement!(:cash_balance_cents, transfer_item.cash_cents)
          receiver.increment!(:cash_balance_cents, transfer_item.cash_cents)
          receiver.delist_non_self_listed_team_players if receiver.should_be_back_in_the_black
        elsif transfer_item.transfer_item_type === "Player"
          contract = transfer_item.team_player.current_contract
					contract.update_attributes!(signed: false, team: receiver, starts_at: Date.today.strftime('%Y-%m-%d'), ends_at: [contract.ends_at, 90.days.from_now].max)
					contract.update_attributes!(signed: true)
          transfer_item.team_player.update_attributes!(team: receiver, first_team: false, squad_position: SquadPosition.find_by(short_name: 'SUB'), transfer_minimum_bid: nil, transfer_completes_at: nil, is_voluntary_transfer: false, is_team_player_initiated_listing: false)
        end
      end
			NewsItem.create(league: self.primary_team.league, news_item_resource_type: 'Transfer', news_item_resource_id: self.id, news_item_type: "transfer_complete", body: "#{self.get_team_player_involved.full_name(true, 17)} signs for #{self.primary_team.abbreviated_title}")
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

  def is_auto_completing
    is_a_transfer_listing && get_team_player_involved.transfer_completes_at
  end

  def transfer_listing_completes_at
    get_team_player_involved.transfer_completes_at
  end

  def is_winning_bid
    get_team_player_involved.get_winning_transfer == self ? true : false
  end

  def get_cash_involved
    get_cash_transfer_item.cash_cents
  end

  def make_counter_offer(team, counter_offer)
    if team_transfer_status(team) != 'accepted'
      get_cash_transfer_item.update_attributes(cash_cents: counter_offer)
      self.update_attributes(primary_team_accepted: self.primary_team == team, secondary_team_accepted: self.secondary_team == team)
    end
  end

  def league_involved
    primary_team.league
  end

  def set_team_player_transfer_completes_at
    team_player_involved = get_team_player_involved
    if is_a_transfer_listing && team_player_involved.transfer_minimum_bid && get_cash_transfer_item.cash_cents >= team_player_involved.transfer_minimum_bid && team_player_involved.number_of_offers == 1
      team_player_involved.update_attributes!(transfer_completes_at: 3.days.from_now)
    end
  end

 	private
 	def teams_in_same_league
 		errors.add(:base, "Teams not in same league.") unless primary_team.league === secondary_team.league
 	end

 	def teams_not_the_same
 		errors.add(:base, "A team cannot make a transfer with itself.") unless primary_team != secondary_team
 	end
end
