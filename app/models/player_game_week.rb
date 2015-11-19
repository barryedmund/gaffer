class PlayerGameWeek < ActiveRecord::Base
	belongs_to :game_week
	belongs_to :player
	validates :game_week_id, :player_id, presence: true
	validates_uniqueness_of :game_week_id, scope: :player_id

	def self.generate_player_game_weeks
		if GameWeek.has_current_game_week?
			current_game_week = GameWeek.get_current_game_week
			Player.all.each do |p|
				PlayerGameWeek.create(player: p, game_week: current_game_week, minutes_played: rand(0..90))
			end
		end
	end
end