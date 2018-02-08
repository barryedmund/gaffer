class StadiumsController < ApplicationController
  before_action :require_user
  before_action :set_stadium, only: [:edit, :update]
  before_action :set_team, only: [:edit, :update]
  before_action :set_league, only: [:edit, :update]
  before_action :stadium_params, only: [:update]

  def show
  end

  def edit
  end

  def save

  end

  def update
    respond_to do |format|
      @expansion = @stadium_params[:capacity].to_i
      @stadium_params[:capacity] = (@stadium.capacity + (@stadium_params[:capacity].to_i)).to_s
      if @stadium.update(@stadium_params)
        @team.update_attributes(cash_balance_cents: @team.cash_balance_cents - (@expansion * Rails.application.config.cost_per_additional_stadium_seat))
        NewsItem.create(league: @league, news_item_resource_type: 'Stadium', news_item_type: 'stadium_expansion', news_item_resource_id: @stadium.id, body: "#{@stadium.abbreviated_name} grows to #{@stadium.capacity} seats", content: "#{@team.abbreviated_title} adds #{@expansion} #{'seat'.pluralize(@expansion)} to stadium.")
        format.html { redirect_to league_team_path(@league, @team), notice: 'Stadium has been expanded.' }
      else
        format.html { redirect_to edit_league_team_stadium_path(@league, @team, @stadium), flash: { error: @stadium.errors.full_messages.join(', ') }}
      end
    end
  end

  private

  def set_stadium
    @stadium = Stadium.find(params[:id])
  end

  def set_team
    @team = @stadium.team
  end

  def set_league
    @league = @team.league
  end

  def stadium_params
    @stadium_params ||= params.require(:stadium).permit(:capacity)
  end
end
