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
      game_round = game_rounds.create(:game_round_number => i, :league_season => self)
    end
    create_games
  end

  def create_games
    game_permutations = Team.where('league_id = ?', self.league.id).to_a.permutation(2).to_a
    ordered_game_weeks = season.game_weeks.order(:starts_at) # 38
    ordered_game_rounds = game_rounds.order(:game_round_number) # 3
    teams = league.teams # 10
    if teams.count == 8
      games_per_game_week = teams.count / 2 # 5
      games_per_season = games_per_game_week * league.competition.game_weeks_per_season # 190
      games_per_game_round = teams.count * (teams.count - 1) # 90
      game_weeks_per_game_round = games_per_game_round / games_per_game_week # 18
      try_games = true

      while try_games
        for i in 0..(game_weeks_per_game_round - 1)
          for j in 0..(game_permutations.length - 1)
            game_permutations.shuffle
            game = Game.new(home_team: game_permutations[j][0], away_team: game_permutations[j][1], game_week: ordered_game_weeks[i], game_round: ordered_game_rounds[0])
            if game.valid?
              game.save!
            end
          end
        end
        if ordered_game_rounds[0].games.count == games_per_game_round
          try_games = false
        else
          Game.where(game_round: ordered_game_rounds[0]).delete_all
        end
      end

      if ordered_game_rounds.length > 1
        for i in 1..(ordered_game_rounds.length - 1)
          remaining_games = games_per_season - get_games.count
          if remaining_games >= games_per_game_round
            ordered_game_rounds[0].games.each do |first_game_round_equivalent|
              this_round_game_week_number = first_game_round_equivalent.game_week.game_week_number + (game_weeks_per_game_round * i)
              this_round_game_week = ordered_game_weeks.where('game_week_number = ?', this_round_game_week_number).first
              Game.create(home_team: first_game_round_equivalent.home_team, away_team: first_game_round_equivalent.away_team, game_week: this_round_game_week, game_round: ordered_game_rounds[i])
            end
          else
            ordered_game_rounds[0].games.each do |first_game_round_equivalent|
              this_round_game_week_number = first_game_round_equivalent.game_week.game_week_number + (game_weeks_per_game_round * i)
              this_round_game_week = ordered_game_weeks.where('game_week_number = ?', this_round_game_week_number).first
              Game.create(home_team: first_game_round_equivalent.home_team, away_team: first_game_round_equivalent.away_team, game_week: this_round_game_week, game_round: ordered_game_rounds[i])
              break if ordered_game_rounds[i].games.count == remaining_games
            end
          end
        end
      end
    end
  end

  def get_games
    game_rounds.joins(:games).all
  end

  def number_of_game_weeks_remaining
    # Is the most recently finished game week number equal to the total number of game weeks?
    season.competition.game_weeks_per_season - season.game_weeks.where(finished: true).order(:starts_at).last.game_week_number
  end

  def is_ready_to_be_wrapped_up
    (number_of_game_weeks_remaining === 0 && !is_completed) ? true : false
  end

  private
  def league_has_an_even_number_of_teams
    errors.add(:base, "Take a leaf out of Noah's book and make sure there is an even number of teams.") unless league.teams.count % 2 == 0
  end
end
