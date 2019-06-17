class ContractsController < ApplicationController
  before_action :require_user
  before_action :set_league
  before_action :set_team
  before_action :set_player, only: [:new, :edit]

  def new
    @contract = Contract.new
  end

  def create
    @contract = Contract.new(contract_params)
    respond_to do |format|
      if @contract.save
        format.html { redirect_to league_contracts_path(@league), notice: 'Contract has been offered.' }
        NewsItem.create(league: @league, news_item_resource_type: 'Contract', news_item_resource_id: @contract.id, body: "#{@contract.player.full_name(true,13)} offered contract")
        if @league.created_at > 1.day.ago && Contract.joins(team: :league).where('leagues.id = ?', @league.id).count == 1
          @league.sign_players_for_zombies
        end
      else
        flash.keep
        format.html { redirect_to new_league_contract_path(@league.id, { player_id: contract_params[:player_id] }), flash: { error: @contract.errors.full_messages.join(', ') }}
      end
    end
  end

  def index
    @contracts = Contract.joins(:team).where('teams.league_id = ?', params[:league_id])
  end

  def edit
    @contract = Contract.find(params[:id])
  end

  def update
    @contract = Contract.find(params[:id])
    respond_to do |format|
      if @contract.update(contract_params)
        format.html { redirect_to league_contracts_path(League.find_by_id(params[:league_id])), notice: 'Contract has been updated.' }
      else
        format.html { redirect_to edit_league_contract_path(@league.id, @contract.id), flash: { error: @contract.errors.full_messages.join(', ') }}
      end
    end
  end

  private
  def contract_params
    params.require(:contract).permit(:league_id, :weekly_salary_cents, :starts_at, :ends_at, :team_id, :player_id)
  end

  def set_league
    @league = League.find(params[:league_id])
  end

  def set_team
    @team = current_user.get_team(@league)
  end

  def set_player
    if params[:player_id]
      @player = Player.find(params[:player_id])
    elsif params[:id]
      @player = Contract.find(params[:id]).player
    end
  end
end
