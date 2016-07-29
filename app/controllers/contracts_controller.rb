class ContractsController < ApplicationController
  before_action :require_user

  def new
    @contract = Contract.new
  end

  def create
    @contract = Contract.new(contract_params)
    respond_to do |format|
      if @contract.save
        format.html { redirect_to league_contracts_path(League.find_by_id(params[:league_id])), notice: 'Contract has been offered.' }
      else
        format.html { render :new }
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
        format.html { render :edit }
      end
    end
  end

  private
  def contract_params
    params.require(:contract).permit(:league_id, :weekly_salary_cents, :starts_at, :ends_at, :team_id, :player_id)
  end
end
