class AddNextOpponentInfoToPlayer < ActiveRecord::Migration
  def change
    add_column :players, :active_game_week_opponent, :string
    add_column :players, :active_game_week_location, :string
  end
end
