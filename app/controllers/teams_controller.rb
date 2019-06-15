class TeamsController < ApplicationController
  before_action :require_user
  before_action :set_team, only: [:show, :edit, :update, :destroy]
  before_action :set_team_from_param, only: [:display]

  # GET /teams
  # GET /teams.json
  def index
    @teams = current_user.teams
  end

  # GET /teams/1
  # GET /teams/1.json
  def show
  end

  def display
  end

  # GET /teams/new
  def new
    @team = current_user.teams.new
    @team.build_stadium
  end

  # GET /teams/1/edit
  def edit
  end

  # POST /teams
  # POST /teams.json
  def create
    @team = current_user.teams.new(team_params)
    @league = League.find_by(id: params[:league_id])
    @team.league = @league
    if @team.save
      LeagueInvite.where(email: current_user.email, league: @league).destroy_all
      flash[:success] = "Added team to league"
      if @league.teams.count == 10 && current_season = Season.current.first
        if LeagueSeason.where(league: @league, season: current_season).count == 0 && !current_season.is_completed
          LeagueSeason.create(league: @league, season: current_season)
        end
      end
      redirect_to league_path(@league)
    else
      render action: :new
    end
  end

  # PATCH/PUT /teams/1
  # PATCH/PUT /teams/1.json
  def update
    respond_to do |format|
      if @team.update(team_params)
        format.html { redirect_to league_team_path, notice: 'Team was successfully updated.' }
        format.json { render :show, status: :ok, location: @team }
      else
        format.html { render :edit }
        format.json { render json: @team.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /teams/1
  # DELETE /teams/1.json
  def destroy
    @team.destroy
    respond_to do |format|
      format.html { redirect_to league_teams_url, notice: 'Team was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_team
      @team = current_user.teams.find(params[:id])
    end

    def set_team_from_param
      @team = Team.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def team_params
      params.require(:team).permit(:title, :league_id, :cash_balance_cents, stadium_attributes: [:capacity, :name])
    end
end
