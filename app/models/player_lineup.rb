class PlayerLineup < ActiveRecord::Base
	belongs_to :player_game_week
	belongs_to :team
	belongs_to :squad_position
	validates :player_game_week_id, :team_id, :squad_position_id, presence: true
  validates_uniqueness_of :player_game_week, scope: [:team]

  def get_attacking_contribution
    attacking_contribution = 0
    if squad_position.short_name === 'GK'
      attacking_contribution += (player_game_week.goals + (player_game_week.assists.to_i * 0.5))
    elsif squad_position.short_name === 'DF'
      attacking_contribution += (player_game_week.goals + (player_game_week.assists.to_i * 0.4))
    elsif squad_position.short_name === 'MD'
      attacking_contribution += (player_game_week.goals + (player_game_week.assists.to_i * 0.3))
    elsif squad_position.short_name === 'FW'
      attacking_contribution += (player_game_week.goals + (player_game_week.assists.to_i * 0.2))
    end
    attacking_contribution.round(1)
  end

  def get_defensive_contribution
    clean_sheet_minutes = player_game_week.minutes_played > 0 ? (player_game_week.minutes_played.to_f / (player_game_week.goals_conceded + 1)) : 0.0
    if squad_position.short_name === 'MD'
      clean_sheet_minutes = clean_sheet_minutes / 2
    elsif squad_position.short_name === 'FW'
      clean_sheet_minutes = 0.0
    end
    clean_sheet_minutes.round(1)
  end
end
