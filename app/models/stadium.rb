class Stadium < ActiveRecord::Base
  belongs_to :team
  validates :name, :capacity, presence: true
  validates_uniqueness_of :team
  validate :team_has_enough_money, :capacity_is_realistic, on: :update

  def abbreviated_name(cut_off = 13)
    working_name = name
    if working_name.length >= cut_off
      working_name = working_name[0, cut_off - 1] + '...'
    end
    working_name
  end

  private

  def team_has_enough_money
    errors.add(:base, "Not enough cash for that expansion.") unless self.capacity == nil || self.team.cash_balance_cents >= ((self.capacity - self.capacity_was) * Rails.application.config.cost_per_additional_stadium_seat)
  end

  def capacity_is_realistic
    errors.add(:base, "Max stadium size is #{Rails.application.config.max_stadium_size} seats.") unless self.capacity == nil || self.capacity <= Rails.application.config.max_stadium_size
  end
end
