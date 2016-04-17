class Season < ActiveRecord::Base
	has_many :league_seasons, dependent: :destroy
	belongs_to :competition
	validates :competition, presence: true
	after_create :create_league_seasons

	def self.current
    where("starts_at <= :date AND ends_at >= :date", date: Date.today).first
  end

	private
	def create_league_seasons
		League.where('competition_id = ?', competition.id).each do |league|
			league_seasons.create(:league => league, :season => self)
		end
	end
end
