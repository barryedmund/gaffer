class SquadPosition < ActiveRecord::Base
	has_many :team_players
	has_many :player_lineups
	validates :short_name, presence: true

  def self.long_name_to_short_name(position_long_name)
    squad_position = SquadPosition.where(long_name: position_long_name).first
    if squad_position
      squad_position.short_name
    else
      position_long_name
    end
  end
end
