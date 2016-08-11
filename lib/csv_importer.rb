require 'csv'

class CSVImporter
  def self.import_games(data)
    imported = []
    failed = []

    CSV.parse(data, :headers => true) do |row|
      game = Game.new(home_team_id: row.field("home_team_id"), away_team_id: row.field("away_team_id"), game_week_id: row.field("game_week_id"), game_round_id: row.field("game_round_id"))

      if game.save
        imported << "#{game.home_team_id}, #{game.away_team_id}, #{game.game_week_id}, #{game.game_round_id}"
      else
        failed << "#{game.home_team_id}, #{game.away_team_id}, #{game.game_week_id}, #{game.game_round_id}"
      end
    end

    return imported, failed
  end
end
