class GameWeek < ActiveRecord::Base
	belongs_to :player
	belongs_to :season
	validates :player_id, presence: true
	validates :season_id, presence: true
	validates :sequence_number, presence: true
	validates :starts_at, presence: true
	validates :ends_at, presence: true
end
