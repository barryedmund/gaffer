class AddPlayerReferenceToContracts < ActiveRecord::Migration
  def change
    add_reference :contracts, :player, index: true, null: true
  end
end
