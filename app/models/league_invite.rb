class LeagueInvite < ActiveRecord::Base
  belongs_to :league
  validates :league, :email, presence: true
  validates_uniqueness_of :email, scope: :league
end
