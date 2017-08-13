class AddNewsFieldsToPlayers < ActiveRecord::Migration
  def change
    add_column :players, :news, :string
    add_column :players, :chance_of_playing, :int
  end
end
