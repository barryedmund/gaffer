class AddSortOrderToSquadPosition < ActiveRecord::Migration
  def change
    add_column :squad_positions, :sort_order, :integer, :default => 0
  end
end
