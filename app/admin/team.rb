ActiveAdmin.register Team do
	controller do
	  def scoped_collection
	    Team.unscoped
	  end
	end

	permit_params :title, :user_id, :league_id, :cash_balance_cents, :deleted_at, :number_of_titles

	index do
		selectable_column
		column :id
		column :title
		column :number_of_titles
		column :user
		column :league
		column "Cash balance", :cash_balance_cents do |cash|
			number_to_currency(cash.cash_balance_cents)
		end
		column :deleted_at
		actions
	end

	form do |f|
	  f.semantic_errors
	  f.inputs do
	  	f.input :title
	  	f.input :user, :collection => User.pluck( :email, :id )
	  	f.input :league, :collection => League.pluck( :name, :id )
	  	f.input :cash_balance_cents
	  	f.input :deleted_at, as: :datetime_picker
			f.input :number_of_titles
	  end
	  f.actions
	end
end
