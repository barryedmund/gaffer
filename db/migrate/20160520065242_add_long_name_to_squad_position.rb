class AddLongNameToSquadPosition < ActiveRecord::Migration
  def change
    add_column :squad_positions, :long_name, :string
  end
end
