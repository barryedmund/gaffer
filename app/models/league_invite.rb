class LeagueInvite < ActiveRecord::Base
  belongs_to :league
  validates :league, :email, presence: true
  validates_uniqueness_of :email, scope: :league, message: "has already been sent an invite for this league."
  validates :email, format: { with: /\A[A-Za-z0-9._%+-]+@[A-Za-z0-9\.-]+\.[A-Za-z]+\Z/ , message:  "isn't formatted properly." }
  validate :email_does_not_exist_in_league
  before_save :downcase_email

  def downcase_email
    self.email = email.downcase 
  end

  def email_does_not_exist_in_league
    if self.league.teams.joins(:user).where('users.email = ?', self.email).length > 0
      errors.add(:base, "A team user with that email already exists in this league.")
    end
  end
end
