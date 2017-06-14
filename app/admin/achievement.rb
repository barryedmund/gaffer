ActiveAdmin.register Achievement do
permit_params :name, :award_type

  index do
    selectable_column
    column :name
    column :award_type
    actions
  end

  form do |f|
    f.semantic_errors
    f.inputs do
      f.input :name
      f.input :award_type
    end
    f.actions
  end
end
