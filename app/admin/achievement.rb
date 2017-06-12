ActiveAdmin.register Achievement do
permit_params :name, :type

  index do
    selectable_column
    column :name
    column :type
    actions
  end

  form do |f|
    f.semantic_errors
    f.inputs do
      f.input :name
      f.input :type
    end
    f.actions
  end
end
