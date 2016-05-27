class PlayerLineup < ActiveRecord::Base
	belongs_to :player_game_week
	belongs_to :team
	belongs_to :squad_position
	validates :player_game_week_id, :team_id, :squad_position_id, presence: true
  validates_uniqueness_of :player_game_week, scope: [:team]
end
