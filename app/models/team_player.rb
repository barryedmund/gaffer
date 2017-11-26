class TeamPlayer < ActiveRecord::Base
  belongs_to :team
  belongs_to :player
  belongs_to :squad_position
  has_many :contracts, :dependent => :destroy
  has_many :transfer_items, :dependent => :destroy
  validates :squad_position_id, presence: true
  validate :game_week_deadline_has_not_passed, on: :update
  accepts_nested_attributes_for :contracts, :allow_destroy => :true

  def self.transfer_listed_with_offers
    self.where.not(transfer_completes_at: nil)
  end

  def self.transfer_listed_with_offers_and_past_completion_date
    self.transfer_listed_with_offers.where('transfer_completes_at < ?', Time.now)
  end

  def self.get_best_deal_of_transfer_listed_team_players_at_position(team, position)
    if most_recently_finished_gameweek = GameWeek.get_most_recent_finished
      self.joins(:team, player: :player_game_weeks).where('team_players.transfer_minimum_bid IS NOT NULL AND team_players.team_id != ? AND teams.league_id = ? AND players.playing_position = ? AND player_game_weeks.game_week_id = ? AND player_game_weeks.minutes_played > ?', team.id, team.league_id, position,most_recently_finished_gameweek.id, 0).select{ |team_player| team_player.relative_deal_value >= 50 }.sort_by{ |team_player| team_player.relative_deal_value }.last
    end
  end

  def full_name(abbreviate = false, cut_off = 13)
    if abbreviate
      working_full_name = "#{player.first_name} #{player.last_name}"
      if working_full_name.length >= cut_off
        working_full_name = "#{player.first_name[0]}. #{player.last_name}"
      end
      if working_full_name.length >= cut_off
        working_full_name = working_full_name[0, cut_off - 1] + '...'
      end
      working_full_name
    else
      "#{player.first_name} #{player.last_name}"
    end
  end

  def last_name
    player.last_name
  end

  def current_contract
    self.contracts.where('starts_at <= ? AND signed = ? AND team_id = ?', Date.today, true, team_id).order(starts_at: :desc).first
  end

  def get_squad_position_from_players_playing_position
     SquadPosition.find_by(long_name: player.playing_position)
  end

  def full_name_with_team_name
    "#{player.first_name} #{player.last_name} (#{team.title})"
  end

  def get_season_stats(season)
    player.player_game_weeks.joins(:game_week).where('game_weeks.season_id = ?', season.id)
  end

  def game_week_deadline_has_not_passed
    allowable_fields = ["is_voluntary_transfer", "transfer_minimum_bid", "transfer_completes_at"]
    if player.game_week_deadline_at < Time.now && GameWeek.has_current_game_week && (self.changed & allowable_fields).empty?
      errors.add(:base, "That player's deadline has passed for this gameweek.")
    end
  end

  def get_transfer_listed_player_initial_bid(bidding_team)
    transfer_minimum_bid ? transfer_minimum_bid : [[player.player_value, bidding_team.cash_balance_cents].min, 0].max
  end

  def transfer_listed?
    transfer_minimum_bid ? true : false
  end

  def is_force_transfer_listed?
    transfer_minimum_bid && !is_voluntary_transfer ? true : false
  end

  def active_transfers
    Transfer.incomplete_transfers_with_team_involved(Team.where(id: team.id)).joins(:transfer_items).where('transfer_items.transfer_item_type = ? AND transfer_items.team_player_id = ?', "Player", id)
  end

  def number_of_offers
    active_transfers.count
  end

  def get_winning_transfer
    @active_transfers = active_transfers
    @number_of_offers = @active_transfers.count
    if @number_of_offers === 0
      nil
    elsif @number_of_offers === 1
      @active_transfers.first
    else
      @active_transfers_transfer_items = @active_transfers.joins(:transfer_items).map(&:transfer_items).flatten
      @active_transfers_transfer_items.map{|i| i.id}
      TransferItem.where(id: @active_transfers_transfer_items).where.not(cash_cents: nil).order('cash_cents DESC, created_at').first.transfer
    end
  end

  def force_transfer_list
    new_transfer_minimum_bid = player.player_value
    new_transfer_completes_at = nil
    new_is_voluntary_transfer = false
    
    if transfer_listed?
      if player.player_value > transfer_minimum_bid
        new_transfer_minimum_bid = [transfer_minimum_bid * Rails.application.config.forced_listing_weekly_factor, Rails.application.config.minimum_player_value].max.round
      else
        new_transfer_minimum_bid = [new_transfer_minimum_bid * Rails.application.config.forced_listing_weekly_factor, Rails.application.config.minimum_player_value].max.round
      end
      if number_of_offers > 0
        new_transfer_completes_at = 3.days.from_now
      end
    else
      if number_of_offers > 0
        if get_winning_transfer.get_cash_transfer_item.cash_cents > player.player_value
          new_transfer_completes_at = 3.days.from_now
        else
          active_transfers.each do |transfer|
            transfer.destroy
          end
        end
      end
    end
    self.update_attributes(transfer_minimum_bid: new_transfer_minimum_bid, transfer_completes_at: new_transfer_completes_at, is_voluntary_transfer: new_is_voluntary_transfer)
  end

  def reset_transfer_attributes
    self.update_attributes(transfer_minimum_bid: nil, transfer_completes_at: nil, is_voluntary_transfer: false)
  end

  def relative_value
    (player.player_value / current_contract.weekly_salary_cents).round
  end

  def deal_value
    transfer_listed? ? (player.player_value - transfer_minimum_bid) : 0
  end

  def relative_deal_value
    deal_value > 0 ? (deal_value / current_contract.weekly_salary_cents).round : 0
  end

  def has_active_transfer_bid_from_team(team_to_check)
    is_this_team_player = false
    Transfer.incomplete_transfers_with_team_involved(Team.where(id: team_to_check.id)).map{ |transfer| is_this_team_player = true if transfer.get_team_player_involved == self }
    is_this_team_player
  end

  def move_to_subs_bench
    self.update_attributes(first_team: false, squad_position: SquadPosition.find_by(short_name: 'SUB'))
  end
end
