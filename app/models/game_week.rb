class GameWeek < ActiveRecord::Base
	belongs_to :season
	has_many :player_game_weeks, dependent: :destroy
	has_many :games, dependent: :destroy
	validates :starts_at, :ends_at, :overlap => {:scope => "season_id"}
	validates :starts_at, :ends_at, :game_week_number, presence: true
	validates :game_week_number, numericality: { greater_than: 0 }
	validates :game_week_number, uniqueness: { scope: :season, message: "a game week only happens once per season" }

	def self.has_current_game_week
		self.where('starts_at < ? AND finished = ?', Time.now, false).any?
	end

  def self.get_most_recent_finished
    GameWeek.where(finished: true, financials_processed: true).order(:starts_at).last
  end

  def in_play?
    starts_at < Time.now && !finished
  end

	def do_financials
		credit_gate_receipts
		debit_weekly_salaries
    puts "GW ##{self.game_week_number} financials_processed: #{self.financials_processed}"
    update(financials_processed: true)
    puts "GW ##{self.game_week_number} financials_processed: #{self.financials_processed}"
	end

	def credit_gate_receipts
		games.each do |game|
			home_team = game.home_team
	    gate_receipts_cents = home_team.stadium.capacity * Rails.application.config.revenue_per_ticket
	    home_team.update(cash_balance_cents: (home_team.cash_balance_cents + gate_receipts_cents))
      puts gate_receipts_cents
  	end
  end

  def debit_weekly_salaries
  	games.each do |game|
  		home_team = game.home_team
  		away_team = game.away_team
    	home_team.update(cash_balance_cents: (home_team.cash_balance_cents - get_player_lineup_salary(home_team)))
    	away_team.update(cash_balance_cents: (away_team.cash_balance_cents - get_player_lineup_salary(away_team)))
  	end
  end

  def get_player_lineup_salary(team)
    team_total_weekly_salary = 0
    team.player_lineups.joins(:player_game_week).where('player_game_weeks.game_week_id = ?', self.id).each do |player_lineup|
			if team_player = TeamPlayer.find_by("player_id = ? AND team_id = ?", player_lineup.player_game_week.player.id, team.id)
        puts "#{player_lineup.player_game_week.player.full_name}"
        team_total_weekly_salary += team_player.current_contract.weekly_salary_cents
      end
    end
    team_total_weekly_salary
  end
end
