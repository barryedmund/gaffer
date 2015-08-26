module TeamHelpers

	def visit_team_players(this_team)
		visit "/teams"
		within dom_id_for(this_team) do
			click_link "View team players"
		end
	end
end