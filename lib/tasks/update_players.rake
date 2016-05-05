task :update_players => :environment do
  i = 1
  while Net::HTTP.get_response(URI("http://fantasy.premierleague.com/web/api/elements/#{i}/")).code.to_i == 200
    player_json_raw = Net::HTTP.get(URI("http://fantasy.premierleague.com/web/api/elements/#{i}/"))
    player_json_object = JSON.parse(player_json_raw)
    puts "#{player_json_object['code']}: #{player_json_object['first_name']} #{player_json_object['second_name']}"
    i = i + 1
  end
end
