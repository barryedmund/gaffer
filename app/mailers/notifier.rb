class Notifier < ActionMailer::Base
  # default_url_options[:host] = "localhost:3000"
  default from: "from@example.com"

  def password_reset(user)
  	@user = user
  	mail(to: "#{user.first_name} #{user.last_name} <#{user.email}>",
      from: "password@gafferleague.com",
      subject: "Gaffer: Reset Your Password")
  end

  def league_invitation(email_address, league)
    @league = league
    mail(to: email_address,
      from: "invite@gafferleague.com",
      subject: "Gaffer: You've been invited to join a league")
  end
end
