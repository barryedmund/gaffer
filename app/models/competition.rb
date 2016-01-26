class Competition < ActiveRecord::Base
	has_many :seasons
	has_many :leagues
	validates :country_code, :description, :game_weeks_per_season, presence: true
end
