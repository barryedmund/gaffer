ActiveAdmin.register NewsItem do
  permit_params :league_id, :news_item_resource_type, :news_item_resource_id, :body

  index do
    selectable_column
    column :league
    column :news_item_resource_type
    column :news_item_resource_id
    column :body
    actions
  end

  form do |f|
    f.semantic_errors
    f.inputs do
      f.input :league
      f.input :news_item_resource_type, collection: ['Player']
      f.input :news_item_resource_id
      f.input :body
    end
    f.actions
  end
end
