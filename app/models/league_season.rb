class LeagueSeason < ActiveRecord::Base
  belongs_to :league
  belongs_to :season
  has_many :game_rounds, dependent: :destroy
  has_many :game_weeks, dependent: :destroy
end
