class Contract < ActiveRecord::Base
  belongs_to :team
  belongs_to :team_player
  validates :weekly_salary_cents, :team, :starts_at, :ends_at, presence: true
  validate :has_positive_salary, :has_future_end_date, :has_start_date_before_end_date, on: :create

  private
  def has_positive_salary
    errors.add(:base, "Don't be tight. Weekly salary must be greater than $1000.") unless weekly_salary_cents >= 100000
  end

  def has_future_end_date
    errors.add(:base, "Hey Marty, contracts must end in the future.") unless ends_at > Date.today
  end

  def has_start_date_before_end_date
    errors.add(:base, "You're going the wrong way. Start date must be before end date.") unless ends_at > starts_at
  end
end
