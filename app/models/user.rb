class User < ActiveRecord::Base
	has_secure_password
	has_many :teams, dependent: :destroy
	has_many :leagues

	validates :email, presence: true,
						uniqueness: true,
						format: {
							with: /\A[A-Za-z0-9._%+-]+@[A-Za-z0-9\.-]+\.[A-Za-z]+\Z/
						}

	before_save :downcase_email

	def downcase_email
		self.email = email.downcase
	end

	def generate_password_reset_token!
		update_attribute(:password_reset_token, SecureRandom.urlsafe_base64(48))
	end

	def full_name
		"#{first_name} #{last_name}"
	end

	def first_name_camel_cased
		"#{first_name.downcase.capitalize}"
	end

	def has_league_invites
		LeagueInvite.where(email: email).count > 0 ? true : false
	end

	def only_league
		user_leagues = League.includes(:teams).where('teams.user_id = :current_user OR leagues.user_id = :current_user', {current_user: self}).references(:teams).distinct
		user_leagues.count == 1 ? user_leagues.first : false
	end

	def get_team(league)
		Team.where(league: league, user: self).first
	end
end
