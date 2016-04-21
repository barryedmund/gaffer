class Season < ActiveRecord::Base
	has_many :league_seasons, dependent: :destroy
	belongs_to :competition
	validates :competition, presence: true

	def self.current
    where("starts_at <= :date AND ends_at >= :date", date: Date.today)
  end
end
