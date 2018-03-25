class LeaguesController < InheritedResources::Base
  before_action :require_user

	def new
		@league = League.new
  end

  def create
    @league = League.new(league_params)
    @league.user_id = current_user.id
    if @league.save
      flash[:success] = "Added league"
      9.times do
        user_password = Faker::Internet.password(10, 20)
        fake_team_user = User.new(first_name: Faker::Name.first_name, last_name: Faker::Name.last_name, email: Faker::Internet.email, last_seen_at: 1.year.ago, password: user_password, password_confirmation: user_password)
        if fake_team_user.save
          fake_team = Team.new(title: "#{Faker::Superhero.descriptor.titleize} #{Faker::Team.creature.titleize}", league: @league, cash_balance_cents: Rails.application.config.team_starting_cash, user: fake_team_user)
          if fake_team.save
            Stadium.create(team: fake_team, name: Faker::Address.street_name.titleize, capacity: Rails.application.config.stadium_starting_capacity)
          end
        end
      end
      redirect_to new_league_team_path(@league.id)
    else
      render action: :new
    end
  end

  def index
    @leagues = League.includes(:teams).where('teams.user_id=? OR leagues.user_id=?', current_user, current_user).references(:teams).distinct
  end

	private
	def league_params
  		params.require(:league).permit(:name, :user_id, :competition_id)
	end
end
