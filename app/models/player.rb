class Player < ActiveRecord::Base
	belongs_to :competition
  has_many :team_players, dependent: :destroy
	has_many :player_game_weeks, dependent: :destroy
  has_many :contracts, dependent: :destroy
  # Polymorhic association with news_items
  has_many :news_items, as: :news_item_resource
	validates :first_name, :last_name, :playing_position, :pl_player_code, :competition, presence: true

  def self.search(search)
    where("lower(first_name) LIKE :search OR lower(last_name) LIKE :search OR lower(playing_position) LIKE :search OR lower(real_team_short_name) LIKE :search", {search: "%#{search.downcase}%"})
  end

  def self.get_all_unattached_players(league)
    Player.where(available: true).where.not(id: (Player.joins(team_players: [:team => :league]).where('leagues.id = ?', league.id) ).map(&:id))
  end

  def self.get_all_unattached_players_sorted_by_value(league)
    if most_recently_finished_gameweek = GameWeek.get_most_recent_finished
      self.get_all_unattached_players(league).joins(:player_game_weeks).where('player_game_weeks.game_week_id = ? AND player_game_weeks.minutes_played >= ?', most_recently_finished_gameweek.id, 90).sort_by{ |player| player.player_value(Season.current.first) }.last(12).sample
    end
  end

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

  def short_playing_position
    SquadPosition.long_name_to_short_name(playing_position)
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

  def percentage_of_minutes_played(season)
    eligible_game_weeks(season) > 0 ? (total_minutes_played(season).to_f / (eligible_game_weeks(season) * 90).to_f).round(3) : 0
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

  def total_attacking_contribution_per_90(season)
    total_minutes_played = total_minutes_played(season)
    total_minutes_played > 0 ? (total_attacking_contribution(season) / (total_minutes_played.to_f / 90)).round(3) : (0.to_f).round(3)
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

  def total_defensive_contribution_per_90(season)
    total_minutes_played = total_minutes_played(season)
    total_minutes_played > 0 ? (total_defensive_contribution(season) / (total_minutes_played.to_f / 90)).round(3) : (0.to_f).round(3)
  end

  def eligible_game_weeks(season)
    player_game_weeks.joins(:game_week).where('game_weeks.season_id = ?', season.id).count
  end

  def opponent_location_short
    if active_game_week_location
      active_game_week_location == 'home' ? 'H' : 'A'
    end
  end

  def past_gameweek_deadline?
    game_week_deadline_at ? (team_player.player.game_week_deadline_at > Time.now) : false
  end

  def player_value(season = Season.current.first)
    defensive_index = ((total_defensive_contribution_per_90(season) / 90) * percentage_of_minutes_played(season)) / 4
    attacking_index = ((total_attacking_contribution_per_90(season)) * percentage_of_minutes_played(season))
    value = ((defensive_index + attacking_index) * 10000000) * 1.5
    [value, Rails.application.config.minimum_player_value].max.round
  end
end
