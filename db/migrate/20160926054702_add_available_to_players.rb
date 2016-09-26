class AddAvailableToPlayers < ActiveRecord::Migration
  def change
    add_column :players, :available, :boolean, default: false
  end
end
