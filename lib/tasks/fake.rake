task :fake => :environment do

	league_user = User.find_by_id(23)

	league = League.create(
		user_id: league_user.id,
		competition_id: 1,
		name: "#{Faker::Book.title} League")

	Team.create(
		title: Faker::Team.name,
		league: league,
		user: league_user)

	3.times do
		user = User.create(
			first_name: Faker::Name.first_name,
			last_name: Faker::Name.last_name,
			email: Faker::Internet.email,
			password: "testing123",
			password_confirmation: "testing123")
		Team.create(
			title: Faker::Team.name,
			league: league,
			user: user)
	end

	Team.all.each do |team|

		goalie_player = Player.create(
			first_name: Faker::Name.first_name,
			last_name: Faker::Name.last_name)
		goalie_team_player = TeamPlayer.create(
			team: team,
			player: goalie_player,
			squad_position: SquadPosition.where('short_name = ?', 'GK').first,
			first_team: true)
		create_player_lineups(goalie_team_player)
		
		10.times do
			non_goalie_player = Player.create(
				first_name: Faker::Name.first_name,
				last_name: Faker::Name.last_name)
			squad_position_offset = rand(SquadPosition.where('short_name != ? AND short_name != ?', 'SUB', 'GK').count)
			squad_position = SquadPosition.where('short_name != ? AND short_name != ?', 'SUB', 'GK').offset(squad_position_offset).first
			non_goalie_team_player = TeamPlayer.create(
				team: team,
				player: non_goalie_player,
				squad_position: squad_position,
				first_team: true)
			create_player_lineups(non_goalie_team_player)
		end

		5.times do
			sub_player = Player.create(
				first_name: Faker::Name.first_name,
				last_name: Faker::Name.last_name)
			sub_team_player = TeamPlayer.create(
				team: team,
				player: sub_player,
				squad_position: SquadPosition.where('short_name = ?', 'SUB').first,
				first_team: false)
			create_player_lineups(sub_team_player)
		end
	end
	league.create_game_rounds
	league.create_games
	Game.all.each do |game|
		game.calculate_score
	end
end

def create_player_lineups(team_player)
		GameWeek.all.each do |game_week|
			player_game_week = PlayerGameWeek.create(
				game_week: game_week,
				player: team_player.player,
				minutes_played: rand(0..90))
			PlayerLineup.create(
				team: team_player.team,
				player_game_week: player_game_week,
				squad_position: team_player.squad_position)
		end
end
