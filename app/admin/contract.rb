ActiveAdmin.register Contract do
  permit_params :team_id, :team_player_id, :player_id, :weekly_salary_cents, :starts_at, :ends_at, :signed

  index do
    selectable_column
    column :id
    column 'League' do |contract|
      contract.team.league.name
    end
    column :team
    column 'Player' do |contract|
      contract.player.full_name
    end
    column :weekly_salary_cents do |contract|
      number_to_currency(contract.weekly_salary_cents / 100)
    end
    column :starts_at
    column :ends_at
    column 'Value' do |contract|
      number_to_currency(contract.value / 100)
    end
    column :signed
    actions
  end
end
