task :update_players => :environment do
  i = 1
  player_competition = Competition.find_by description: 'Premier League'
  while Net::HTTP.get_response(URI("http://fantasy.premierleague.com/web/api/elements/#{i}/")).code.to_i == 200
    player_json_raw = Net::HTTP.get(URI("http://fantasy.premierleague.com/web/api/elements/#{i}/"))
    player_json_object = JSON.parse(player_json_raw)
    player = Player.create(first_name: player_json_object['first_name'], last_name: player_json_object['second_name'], playing_position: player_json_object['type_name'], pl_player_code: player_json_object['code'], competition: player_competition)
    puts player.full_name
    i = i + 1
  end
end
