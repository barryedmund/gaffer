class Competition < ActiveRecord::Base
	has_many :seasons
	has_many :leagues
	validates :country_code, :description, :rounds_per_season, presence: true
end
