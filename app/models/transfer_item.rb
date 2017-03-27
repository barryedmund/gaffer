class TransferItem < ActiveRecord::Base
  belongs_to :transfer, touch: true
  belongs_to :sending_team, :class_name => 'Team', :foreign_key => 'sending_team_id'
  belongs_to :receiving_team, :class_name => 'Team', :foreign_key => 'receiving_team_id'
  belongs_to :team_player
  validates :transfer, :sending_team, :receiving_team, :transfer_item_type, presence: true
  validates :transfer_item_type, inclusion: { in: ['Cash', 'Player'] }
  validate  :cash_transfer_items_have_positive_cash,
            :cash_transfer_items_do_not_have_team_player,
            :player_trasnfer_item_to_have_team_player,
            :player_transfer_items_do_not_have_cash_cents,
            :sending_team_owns_player,
            :teams_involved_different,
            :teams_in_same_league,
            :only_one_of_each_transfer_item_type, 
            on: :create
  validate :cash_bid_is_not_below_minimum_bid
  validate :sending_team_has_enough_money


  def get_league
    sending_team.league
  end

  def get_team_player_in_transfer
    transfer.transfer_items.each do |this_transfer_item|
      if this_transfer_item.transfer_item_type == "Player"
        return TeamPlayer.find_by(id: this_transfer_item.team_player_id)
      end
    end
    return nil
  end

  private

  def only_one_of_each_transfer_item_type
    errors.add(:base, "You can only make one offer on the same player.") if transfer.transfer_items.where('transfer_items.transfer_item_type = ?', 'Cash').count > 0
  end

  def cash_bid_is_not_below_minimum_bid
    errors.add(:base, "Offer cannot be below listing price.") unless
      transfer_item_type != "Cash" ||
      !get_team_player_in_transfer ||
      !get_team_player_in_transfer.transfer_listed? ||
      (transfer_item_type === "Cash" && cash_cents != nil && cash_cents > 0 && !get_team_player_in_transfer.transfer_minimum_bid) || 
      (transfer_item_type === "Cash" && cash_cents != nil && cash_cents > 0 && cash_cents >= get_team_player_in_transfer.transfer_minimum_bid)
  end

  def cash_transfer_items_have_positive_cash
    errors.add(:base, "Cash must be positive for cash transfer items.") unless transfer_item_type != "Cash" || (transfer_item_type === "Cash" && cash_cents != nil && cash_cents > 0)
  end

  def cash_transfer_items_do_not_have_team_player
    errors.add(:base, "No players are involved in cash transfer items.") unless transfer_item_type != "Cash" || (transfer_item_type === "Cash" && team_player === nil)
  end

  def player_trasnfer_item_to_have_team_player
    errors.add(:base, "Player must be involved in player transfer items.") unless transfer_item_type != "Player" || (transfer_item_type === "Player" && team_player != nil)
  end

  def player_transfer_items_do_not_have_cash_cents
    errors.add(:base, "No cash is involved in player transfer items.") unless transfer_item_type != "Player" || (transfer_item_type === "Player" && team_player != nil && cash_cents === nil)
  end

  def sending_team_owns_player
    errors.add(:base, "Sending team does not own that player.") unless transfer_item_type != "Player" || (transfer_item_type === "Player" && team_player != nil && team_player.team === sending_team)
  end

  def teams_in_same_league
    errors.add(:base, "Teams not in same league.") unless sending_team.league === receiving_team.league
  end

  def teams_involved_different
    errors.add(:base, "Transfer items can not be from and to the same team.") unless sending_team != receiving_team
  end

  def sending_team_has_enough_money
    errors.add(:base, "Not enough money.") unless transfer_item_type != "Cash" || cash_cents === nil || sending_team.cash_balance_cents >= cash_cents
  end
end
