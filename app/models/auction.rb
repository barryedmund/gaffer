class Auction < ActiveRecord::Base
  belongs_to :team_player
  validates :team_player_id, :minimum_bid, :is_voluntary, :is_active, presence: true
end
