class AddElementIdToPlayer < ActiveRecord::Migration
  def change
    add_column :players, :pl_element_id, :integer
  end
end
