class LeagueSeason < ActiveRecord::Base
  belongs_to :league
  belongs_to :season
  has_many :game_rounds, dependent: :destroy
  has_many :game_weeks, dependent: :destroy
  after_create :create_game_weeks

  def create_game_rounds
    number_of_teams = league.teams.count
    games_per_game_round = number_of_teams * (number_of_teams - 1)
    game_weeks_per_game_round = games_per_game_round / (number_of_teams / 2)
    game_rounds_per_season = (league.competition.game_weeks_per_season / game_weeks_per_game_round.to_f).ceil
    (1..game_rounds_per_season).each do |i|
      game_rounds.create(:game_round_number => i, :league_season => self)
    end
    create_games
  end

  def create_games
    game_permutations = Team.where('league_id = ?', self.league.id).to_a.permutation(2).to_a.shuffle
    ordered_game_weeks = game_weeks.order(:starts_at)
    ordered_game_rounds = game_rounds.order(:game_round_number)
    game_round_counter = 0
    teams = league.teams
    games_per_game_round = teams.count * (teams.count - 1)
    games_per_game_week = teams.count / 2
    ordered_game_weeks.each do |game_week|
      if league.get_games.where("league_id = ? AND game_round_id = ?", self.league, ordered_game_rounds[game_round_counter].id).count == games_per_game_round
          game_round_counter += 1
      end
      game_permutations.each do |game_perm|
        game = Game.new(:home_team => game_perm[0], :away_team => game_perm[1], :game_week => game_week, :game_round => ordered_game_rounds[game_round_counter])
        if game.valid?
          game.save!
          if league.get_games.where("league_id = ? AND game_week_id = ?", self.league, game_week.id).count >= games_per_game_week
            break
          end
        end
      end
    end
    if league.get_games.count != (games_per_game_week * league.competition.game_weeks_per_season)
      league.get_games.delete_all
      create_games
    end
  end

  private
  def create_game_weeks
    competition = league.competition
    required_game_weeks = competition.game_weeks_per_season
    current_start_at_date = season.starts_at
    current_ends_at_date = current_start_at_date + 7
    while game_weeks.count < required_game_weeks do
      game_weeks.create(:starts_at => current_start_at_date, :ends_at => current_ends_at_date)
      current_start_at_date = game_weeks.last.ends_at + 1
      current_ends_at_date = current_start_at_date + 7
    end
    create_game_rounds
  end
end
