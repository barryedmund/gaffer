class LeagueSeason < ActiveRecord::Base
  belongs_to :league
  belongs_to :season
  has_many :game_rounds, dependent: :destroy
  has_many :team_achievements, dependent: :destroy
  validate :league_has_an_even_number_of_teams, on: :create
  after_create :create_game_rounds

  def create_game_rounds
    number_of_teams = league.teams.where(deleted_at: nil).count
    games_per_game_round = number_of_teams * (number_of_teams - 1)
    game_weeks_per_game_round = games_per_game_round / (number_of_teams / 2)
    game_rounds_per_season = (league.competition.game_weeks_per_season / game_weeks_per_game_round.to_f).ceil
    (1..game_rounds_per_season).each do |i|
      game_round = game_rounds.create(:game_round_number => i, :league_season => self)
    end
    create_games
  end

  def self.create_games
    teams = ["A", "B", "C", "D", "E", "F"]
    unique_games = []
    (0..(teams.count - 2)).each do |i|
      prime_team = teams[i]
      ((i + 1)..(teams.count - 1)).each do |j|
        unique_games << [prime_team, teams[j]]
        unique_games << [teams[j], prime_team]
      end
    end
    puts unique_games.inspect
    puts unique_games.count

    number_of_game_weeks = unique_games.count / (teams.count / 2)
    game_week_games = []
    i = 0
    while game_week_games.count < number_of_game_weeks
      game_week_games << []
      j = 0
      # While this game week isn't full
      while (game_week_games[i].count < (teams.count / 2)) && (unique_games.count > 0)

        if game_week_games[i].count == 0
          game_week_games[i] << unique_games[j]
          puts "game added: #{unique_games[j].inspect}"
          unique_games.delete(unique_games[j])
        else
          teams_involved_so_far = game_week_games[i].flatten.uniq
          intersection = teams_involved_so_far & unique_games[j]
          if intersection.empty?
            game_week_games[i] << unique_games[j]
            puts "game added: #{unique_games[j].inspect}"
            unique_games.delete(unique_games[j])
          end
        end
        j = j + 1
      end
      puts "game_week_games: #{game_week_games.inspect}"
      i = i + 1
    end
    puts game_week_games.inspect
    puts game_week_games.count
  end

  def get_games
    game_rounds.joins(:games).all
  end

  def number_of_game_weeks_remaining
    # Is the most recently finished game week number equal to the total number of game weeks?
    season.competition.game_weeks_per_season - season.game_weeks.where(finished: true).order(:starts_at).last.game_week_number
  end

  def is_ready_to_be_wrapped_up
    (number_of_game_weeks_remaining === 0 && !season.is_completed) ? true : false
  end

  def completed_games
    Game.joins(:game_round).where('game_rounds.league_season_id = ?', self.id).where(home_team_score: nil, away_team_score: nil)
  end

  def participating_teams
    completed_games_this_league_season = Game.where(id: self.completed_games.map(&:id))
    home_team_ids = completed_games.uniq.pluck(:home_team_id)
    away_team_ids = completed_games.uniq.pluck(:away_team_id)
    all_team_ids = (home_team_ids + away_team_ids).uniq
    this_league_teams = Team.where(league: self.league)
    this_league_teams.where(id: all_team_ids).where.not(deleted_at: nil) | this_league_teams.where(deleted_at: nil)
  end

  private
  def league_has_an_even_number_of_teams
    errors.add(:base, "Take a leaf out of Noah's book and make sure there is an even number of teams.") unless league.teams.where(deleted_at: nil).count % 2 == 0
  end
end
