class Competition < ActiveRecord::Base
	has_many :seasons, dependent: :destroy
	has_many :leagues, dependent: :destroy
  has_many :players, dependent: :destroy
	validates :country_code, :description, :game_weeks_per_season, presence: true

  def current_season
    seasons.where("starts_at <= :date AND ends_at >= :date", date: Date.today).first
  end
end
