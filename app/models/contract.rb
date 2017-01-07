class Contract < ActiveRecord::Base
  belongs_to :team
  belongs_to :team_player
  belongs_to :player
  validates :weekly_salary_cents, :team, :starts_at, :ends_at, :player_id, presence: true
  validate :has_positive_salary, :has_future_end_date, :has_start_date_before_end_date, :is_a_valid_length, :one_signed_contract_per_team_player

  def is_signed_and_current?
    if signed && (starts_at <= Time.now) && (ends_at > Time.now)
      true
    else
      false
    end
  end

  def value
    number_of_weeks = (((ends_at - starts_at).to_i) / 7).floor
    number_of_weeks * weekly_salary_cents
  end

  def self.next_contract_settlement_date
    (Time.now+(Time.now.hour >= 7 ? 1 : 0).day).to_date
  end

  def release_value
    release_val = weekly_salary_cents * 20
    release_val
  end

  private
  def has_positive_salary
    errors.add(:base, "Don't be tight. Weekly salary must be greater than $25,000.") unless weekly_salary_cents && (weekly_salary_cents >= 25000)
  end

  def has_future_end_date
    errors.add(:base, "Hey Marty, contracts must end in the future.") unless ends_at && (ends_at > Date.today)
  end

  def has_start_date_before_end_date
    errors.add(:base, "You're going the wrong way. Start date must be before end date.") unless ends_at && starts_at && (ends_at > starts_at)
  end

  def is_a_valid_length
    errors.add(:base, "Contracts must be 1 - 4 years in length.") unless ends_at && starts_at && (ends_at - starts_at >= 365) && (ends_at - starts_at <= 1461)
  end

  def one_signed_contract_per_team_player
    errors.add(:base, "A team player can only sign one contract at a time") unless !self.signed? || (self.signed? && self.team_player.contracts.where('contracts.signed = ?', true).count == 0)
  end
end
