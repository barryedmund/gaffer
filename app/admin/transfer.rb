ActiveAdmin.register Transfer do
	permit_params :primary_team_id, :secondary_team_id, :primary_team_accepted, :secondary_team_accepted

	index do
		selectable_column
		column :id
		column :primary_team
		column :secondary_team
		column :primary_team_accepted
		column :secondary_team_accepted
		actions
	end

	form do |f|
	  f.semantic_errors
	  f.inputs do
	  	f.input :primary_team, :collection => Team.all.map{ |team| ["#{team.title} (#{team.league.name})", team.id]}
	  	f.input :secondary_team, :collection => Team.all.map{ |team| ["#{team.title} (#{team.league.name})", team.id]}
	  	f.input :primary_team_accepted
	  	f.input :secondary_team_accepted
	  end
	  f.actions
	end
end
