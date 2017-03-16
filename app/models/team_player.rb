class TeamPlayer < ActiveRecord::Base
  belongs_to :team
  belongs_to :player
  belongs_to :squad_position
  has_many :contracts, :dependent => :destroy
  has_many :transfer_items, :dependent => :destroy
  validates :squad_position_id, presence: true
  validate :game_week_deadline_has_not_passed, on: :update
  validates_presence_of :transfer_minimum_bid, :if => :transfer_completes_at?
  accepts_nested_attributes_for :contracts, :allow_destroy => :true

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
    if player.game_week_deadline_at < Time.now
      errors.add(:base, "That player's deadline has passed for this gameweek.")
    end
  end

  def get_transfer_listed_player_initial_bid
    transfer_minimum_bid ? transfer_minimum_bid : [[player.player_value(Season.current.first), team.cash_balance_cents].min, 0].max
  end

  def transfer_listed?
    transfer_minimum_bid ? true : false
  end

  def active_transfers
    Transfer.incomplete_transfers_with_team_involved(team).joins(:transfer_items).where('transfer_items.transfer_item_type = ? AND transfer_items.team_player_id = ?', "Player", id)
  end

  def number_of_offers
    active_transfers.count
  end
end
