class Season < ActiveRecord::Base
	has_many :game_weeks
	belongs_to :competition
	validates :competition, presence: true

	def self.current
    	where("starts_at <= :date AND ends_at >= :date", date: DateTime.now)
  	end
end
