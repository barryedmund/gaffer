class AddCashBalanceCentsToTeams < ActiveRecord::Migration
  def change
    add_column :teams, :cash_balance_cents, :bigint
  end
end
