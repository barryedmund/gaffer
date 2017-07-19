ActiveAdmin.register LeagueSeason do
  permit_params :league_id, :season_id

  index do
    column :id
    column :league
    column :season do |ls|
      ls.season.description
    end
    column :is_completed do |ls|
      ls.season.is_completed
    end
    actions
  end

  form do |f|
    f.semantic_errors
    f.inputs do
      f.input :league
      f.input :season, :collection => Season.pluck( :description, :id )
    end
    f.actions
  end
end
