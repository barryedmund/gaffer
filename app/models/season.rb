class Season < ActiveRecord::Base
	has_many :league_seasons, dependent: :destroy
  has_many :game_weeks, dependent: :destroy
	belongs_to :competition
	validates :competition, presence: true
  after_create :create_game_weeks

	def self.current
    where("starts_at <= :date AND ends_at >= :date", date: Date.today)
  end

  def get_current_game_week
    previous_game_week = game_weeks.order(starts_at: :desc).where('ends_at < ?', Time.now).first
    next_game_week = game_weeks.order(:starts_at).where('starts_at > ?', Time.now).first
    if previous_game_week
      if !previous_game_week.finished
        previous_game_week
      else
        if next_game_week
          next_game_week
        end
      end
    else
      if next_game_week
        next_game_week
      end
    end
  end

  private
  def create_game_weeks
    required_game_weeks = competition.game_weeks_per_season
    current_start_at_date = starts_at
    current_ends_at_date = current_start_at_date + 7
    i = 1
    while game_weeks.count < required_game_weeks do
      game_weeks.create(:starts_at => current_start_at_date, :ends_at => current_ends_at_date, game_week_number: i)
      current_start_at_date = game_weeks.last.ends_at + 1
      current_ends_at_date = current_start_at_date + 7
      i = i + 1
    end
  end
end
