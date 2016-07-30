ActiveAdmin.register Team do
	permit_params :title, :user_id, :league_id, :cash_balance_cents

	index do
		selectable_column
		column :id
		column :title
		column :user
		column :league
		column "Cash balance", :cash_balance_cents do |cash|
			number_to_currency(cash.cash_balance_cents)
		end
		actions
	end

	form do |f|
	  f.semantic_errors
	  f.inputs do
	  	f.input :title
	  	f.input :user, :collection => User.pluck( :email, :id )
	  	f.input :league, :collection => League.pluck( :name, :id )
	  	f.input :cash_balance_cents
	  end
	  f.actions
	end
end
