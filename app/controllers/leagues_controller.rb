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
      redirect_to leagues_path
    else
      flash[:error] = "There was a problem adding that team."
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