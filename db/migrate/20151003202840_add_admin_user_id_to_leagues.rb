class AddAdminUserIdToLeagues < ActiveRecord::Migration
  def change
    add_reference :leagues, :user, index: true
  end
end
