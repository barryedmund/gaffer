class Player < ActiveRecord::Base
	belongs_to :competition
  has_many :team_players, dependent: :destroy
	has_many :player_game_weeks, dependent: :destroy
  has_many :contracts, dependent: :destroy
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

  def sort_val
    return 0 if self.playing_position == 'Goalkeeper'
    return 1 if self.playing_position == 'Defender'
    return 2 if self.playing_position == 'Midfielder'
    return 3 if self.playing_position == 'Forward'
  end
end
