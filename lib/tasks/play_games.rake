task :play_games => :environment do
  Game.all.each do |game|
    game.calculate_score
  end
end
