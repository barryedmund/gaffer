class FixTypeColumnName < ActiveRecord::Migration
  def up
    rename_column :achievements, :type, :award_type
  end
end
