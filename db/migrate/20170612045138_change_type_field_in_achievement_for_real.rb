class ChangeTypeFieldInAchievementForReal < ActiveRecord::Migration
  def up
    change_column :achievements, :type, 'integer USING CAST(type AS integer)'
  end

  def down
    change_column :achievements, :type, :string
  end
end
