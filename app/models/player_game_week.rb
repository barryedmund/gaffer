class PlayerGameWeek < ActiveRecord::Base
	belongs_to :game_week
	belongs_to :player
	has_many :player_lineups, dependent: :destroy
	validates :game_week_id, :player_id, :minutes_played, :goals, presence: true
	validates_uniqueness_of :game_week_id, scope: :player_id
end
