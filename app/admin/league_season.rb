ActiveAdmin.register LeagueSeason do
  permit_params :league_id, :season_id, :is_completed

  index do
    column :id
    column :league
    column :season do |ls|
      ls.season.description
    end
    column :is_completed
    actions
  end

  form do |f|
    f.semantic_errors
    f.inputs do
      f.input :league
      f.input :season, :collection => Season.pluck( :description, :id )
      f.input :is_completed
    end
    f.actions
  end
end
