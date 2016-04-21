ActiveAdmin.register LeagueSeason do
  permit_params :league_id, :season_id

  form do |f|
    f.semantic_errors
    f.inputs do
      f.input :league
      f.input :season, :collection => Season.pluck( :description, :id )
    end
    f.actions
  end
end
