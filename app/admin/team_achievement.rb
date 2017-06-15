ActiveAdmin.register TeamAchievement do
permit_params :team, :league_Season, :achievement, :details

  index do
    selectable_column
    column :team
    column 'Achievement' do |team_achievement|
      team_achievement.achievement.name
    end
    column :details
    column 'Season' do |team_achievement|
      team_achievement.league_season.season.description
    end
    actions
  end

  form do |f|
    f.semantic_errors
    f.inputs do
      f.input :team
      f.input :achievement
      f.input :league_Season
      f.input :details
    end
    f.actions
  end
end
