task :play_games => :environment do
  Game.all.each do |game|
    game.calculate_score
    game.credit_gate_receipts
    game.debit_weekly_salaries
  end
end
