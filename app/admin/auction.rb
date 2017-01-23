ActiveAdmin.register Auction do
  index do
    selectable_column
    column :id
    column 'Player' do |auction|
      auction.team_player.full_name
    end
    column 'Team' do |auction|
      auction.team_player.team.title
    end
    column :minimum_bid
    column :is_voluntary
    column :is_active
    column :active_until
    actions
  end
end
