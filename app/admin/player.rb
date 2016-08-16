ActiveAdmin.register Player do
	permit_params :first_name, :last_name, :competition_id

  index do
    selectable_column
    column :id
    column :first_name
    column :last_name
    column :playing_position
    column :pl_player_code
    column :pl_element_id
    actions
  end
end
