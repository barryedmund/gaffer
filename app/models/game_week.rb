class GameWeek < ActiveRecord::Base
	belongs_to :season
	validates :season_id, presence: true
	validates :starts_at, presence: true
	validates :ends_at, presence: true
end
