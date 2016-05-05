class RenamePlayerPositionColumn < ActiveRecord::Migration
  def change
    rename_column :players, :position, :playing_position
  end
end
