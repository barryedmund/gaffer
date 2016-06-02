ActiveAdmin.register LeagueInvite do
  permit_params :league_id, :email

  index do
    selectable_column
    column :id
    column :league
    column :email
    actions
  end
end
