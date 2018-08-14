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

  def create_games
    competition = league.competition
    competition_game_weeks = competition.game_weeks_per_season

    teams_in_league = league.teams.where(deleted_at: nil).to_a
    number_of_teams_in_league = teams_in_league.count

    game_weeks_remaining = number_of_game_weeks_remaining || competition_game_weeks
    games_per_game_round = (number_of_teams_in_league - 1) * 2
    home_teams = teams_in_league[0..((number_of_teams_in_league / 2) - 1)]
    away_teams = teams_in_league[(number_of_teams_in_league / 2)..(number_of_teams_in_league - 1)].reverse

    games = []
    (0..(games_per_game_round - 1)).each do |game_weeks|
      games << []
    end
    (0..(number_of_teams_in_league - 2)).each do |game_week_counter|
      (0..((number_of_teams_in_league / 2) - 1)).each do |games_per_week_counter|
        games[game_week_counter] << [home_teams[games_per_week_counter], away_teams[games_per_week_counter]]
        games[game_week_counter + (number_of_teams_in_league - 1)] << [away_teams[games_per_week_counter], home_teams[games_per_week_counter]]
      end
      team_to_move_up = away_teams[0]
      away_teams.delete(team_to_move_up)
      home_teams.insert(1, team_to_move_up)

      team_to_move_down = home_teams[home_teams.count - 1]
      home_teams.delete(team_to_move_down)
      away_teams << team_to_move_down
    end
    games.shuffle!
    i = 0
    while games.count < competition_game_weeks
      if i == games.count - 1
        i = 0
      end
      games << games[i]
      i = i + 1
    end

    game_weeks_for_rest_of_season = games[0..game_weeks_remaining - 1]
    (0..game_weeks_for_rest_of_season.count - 1).each do |i|
      game_week_number = competition_game_weeks - game_weeks_remaining + 1 + i
      game_week = GameWeek.where(season: season, game_week_number: game_week_number).first
      game_round_number = ((i + 1).to_f / games_per_game_round.to_f).ceil
      game_round = GameRound.where(league_season: self, game_round_number: game_round_number).first
      (0..game_weeks_for_rest_of_season[i].count - 1).each do |j|
        home_team = game_weeks_for_rest_of_season[i][j][0]
        away_team = game_weeks_for_rest_of_season[i][j][1]
        game = Game.new(home_team: home_team, away_team: away_team, game_week: game_week, game_round: game_round)
        if game.valid?
          game.save!
        else
          puts "Game invalid: #{game.inspect}"
        end
      end
    end
    puts Game.joins(:game_round).where('game_rounds.league_season_id = ?', self.id).inspect
  end

  def get_games
    game_rounds.joins(:games).all
  end

  def number_of_game_weeks_remaining
    if last_game_week = season.game_weeks.where(finished: true).order(:starts_at).last
      season.competition.game_weeks_per_season - last_game_week.game_week_number
    else
      season.competition.game_weeks_per_season
    end
  end

  def is_ready_to_be_wrapped_up
    (number_of_game_weeks_remaining === 0 && !season.is_completed) ? true : false
  end

  def completed_games
    Game.joins(:game_round).where('game_rounds.league_season_id = ?', self.id).where(is_complete: false)
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
