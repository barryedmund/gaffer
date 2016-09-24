class Player < ActiveRecord::Base
	belongs_to :competition
  has_many :team_players, dependent: :destroy
	has_many :player_game_weeks, dependent: :destroy
  has_many :contracts, dependent: :destroy

  # Polymorhic association with news_items
  has_many :news_items, as: :news_item_resource

	validates :first_name, :last_name, :playing_position, :pl_player_code, :competition, presence: true

	def full_name(abbreviate = false, cut_off = 13)
    if abbreviate
      working_full_name = "#{first_name} #{last_name}"
      if working_full_name.length >= cut_off
        working_full_name = "#{first_name[0]}. #{last_name}"
      end
      if working_full_name.length >= cut_off
        working_full_name = working_full_name[0, cut_off - 1] + '...'
      end
      working_full_name
    else
      "#{first_name} #{last_name}"
    end
	end

  def full_name_and_playing_position
    "#{first_name} #{last_name} (#{playing_position})"
  end

  def full_name_and_playing_position_and_real_team
    if real_team_short_name
      "#{full_name(true, 19)} (#{SquadPosition.long_name_to_short_name(playing_position)} / #{real_team_short_name})"
    else
      full_name_and_playing_position
    end
  end

  def news_item_display
    full_name_and_playing_position_and_real_team
  end

  def sort_val
    return 0 if self.playing_position == 'Goalkeeper'
    return 1 if self.playing_position == 'Defender'
    return 2 if self.playing_position == 'Midfielder'
    return 3 if self.playing_position == 'Forward'
  end

  def has_current_contract_in_league?(league)
    return_value = false
    contracts.joins(:team).where('teams.league_id = ?', league.id).each do |contract|
      if contract.is_signed_and_current?
        return_value = true
        break
      end
    end
    return_value
  end

  def total_minutes_played(season)
    player_game_weeks.joins(:game_week).where('game_weeks.season_id = ?', season.id).sum(:minutes_played)
  end

  def total_attacking_contribution(season)
    this_season_player_game_weeks = player_game_weeks.joins(:game_week).where('game_weeks.season_id = ?', season.id)
    attacking_contribution = 0
    if playing_position === 'Goalkeeper'
      attacking_contribution += (this_season_player_game_weeks.sum(:goals) + (this_season_player_game_weeks.sum(:assists).to_f * 0.5))
    elsif playing_position === 'Defender'
      attacking_contribution += (this_season_player_game_weeks.sum(:goals) + (this_season_player_game_weeks.sum(:assists).to_f * 0.4))
    elsif playing_position === 'Midfielder'
      attacking_contribution += (this_season_player_game_weeks.sum(:goals) + (this_season_player_game_weeks.sum(:assists).to_f * 0.3))
    elsif playing_position === 'Forward'
      attacking_contribution += (this_season_player_game_weeks.sum(:goals) + (this_season_player_game_weeks.sum(:assists).to_f * 0.2))
    end
    attacking_contribution.round(1)
  end

  def total_defensive_contribution(season)
    this_season_player_game_weeks = player_game_weeks.joins(:game_week).where('game_weeks.season_id = ?', season.id)
    total_clean_sheet_minutes = 0
    this_season_player_game_weeks.each do |player_game_week|
      clean_sheet_minutes = player_game_week.minutes_played > 0 ? (player_game_week.minutes_played.to_f / (player_game_week.goals_conceded + 1)) : 0.0
      if playing_position === 'Midfielder'
        clean_sheet_minutes = clean_sheet_minutes / 2
      elsif playing_position === 'Forward'
        clean_sheet_minutes = 0.0
      end
      total_clean_sheet_minutes += clean_sheet_minutes
    end
    total_clean_sheet_minutes.round(1)
  end

  def eligible_game_weeks(season)
    player_game_weeks.joins(:game_week).where('game_weeks.season_id = ?', season.id).count
  end
end
