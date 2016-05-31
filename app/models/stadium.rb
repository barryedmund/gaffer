class Stadium < ActiveRecord::Base
  belongs_to :team
  validates :name, :capacity, presence: true
  validates_uniqueness_of :team
end
