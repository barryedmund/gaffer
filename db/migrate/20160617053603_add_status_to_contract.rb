class AddStatusToContract < ActiveRecord::Migration
  def change
    add_column :contracts, :signed, :boolean, default: false
  end
end
