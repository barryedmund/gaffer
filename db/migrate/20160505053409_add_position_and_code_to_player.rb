class AddPositionAndCodeToPlayer < ActiveRecord::Migration
  def change
    add_column :players, :position, :string
    add_column :players, :pl_player_code, :integer
  end
end
