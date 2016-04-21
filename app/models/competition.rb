class Competition < ActiveRecord::Base
	has_many :seasons, dependent: :destroy
	has_many :leagues, dependent: :destroy
	validates :country_code, :description, :game_weeks_per_season, presence: true
end
