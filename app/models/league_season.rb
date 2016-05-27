class LeagueSeason < ActiveRecord::Base
  belongs_to :league
  belongs_to :season
  has_many :game_rounds, dependent: :destroy
  validate :league_has_an_even_number_of_teams, on: :create
  after_create :create_game_rounds

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
    ordered_game_weeks = season.game_weeks.order(:starts_at)
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
    if get_games.count != (games_per_game_week * league.competition.game_weeks_per_season)
      get_games.delete_all
      create_games
    end
  end

  def get_games
    game_rounds.joins(:games).all
  end

  private
  def league_has_an_even_number_of_teams
    errors.add(:base, "Take a leaf out of Noah's book and make sure there is an even number of teams.") unless league.teams.count % 2 == 0
  end
end
