module TeamHelpers

	def visit_team_players(this_team)
		visit "leagues/#{this_team.league_id}/teams"
		within dom_id_for(this_team) do
			click_link "#{this_team.title}"
		end
	end
end