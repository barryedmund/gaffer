require 'spec_helper'

describe "Viewing team players" do
	let!(:player) { create(:player) }
	let!(:user) { create(:user) }
  let!(:competition) { create(:competition) }
  let!(:season) { create(:season, competition: competition) }
  let!(:league) { create(:league, competition: competition) }
  let!(:home_team) { Team.create(id: 1, title: "Home Team", league: league, user: user) }
  let!(:team_player) { create(:team_player, :with_contract, team: home_team) }
  let!(:league_season) { LeagueSeason.create(season: season, league: league) }
	let!(:squad_position_1) { SquadPosition.create(short_name: "GK") }
	let!(:squad_position_2) { SquadPosition.create(short_name: "SUB") }
	let!(:squad_position_3) { SquadPosition.create(short_name: "DF") }
	let!(:squad_position_midfielder) { create(:midfielder_squad_position) }
	let!(:stadium) { create(:stadium, team: home_team) }
	before { sign_in user, password: "gaffer123" }

	it "displays the title of the team" do
		visit_team_players(home_team)
		within("h2.mdl-card__title-text") do
			expect(page).to have_content(home_team.title)
		end
	end

	it "displays no team players when a team is empty" do
		visit_team_players(home_team)
		expect(page.all("ul.team_players li").size).to eq(0)
	end
end
