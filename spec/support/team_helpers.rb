module TeamHelpers

	def visit_team_players(this_team)
		visit "leagues/#{this_team.league_id}"
		click_link "#{this_team.title}"
	end
end
