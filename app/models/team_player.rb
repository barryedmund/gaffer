class TeamPlayer < ActiveRecord::Base
  belongs_to :team
  belongs_to :player
  belongs_to :squad_position
  has_many :contracts, :dependent => :destroy
  has_many :transfer_items, :dependent => :destroy
  validates :squad_position_id, presence: true
  accepts_nested_attributes_for :contracts, :allow_destroy => :true

  def full_name(abbreviate = false, cut_off = 13)
    if abbreviate
      working_full_name = "#{player.first_name} #{player.last_name}"
      if working_full_name.length >= cut_off
        working_full_name = "#{player.first_name[0]}. #{player.last_name}"
      end
      if working_full_name.length >= cut_off
        working_full_name = working_full_name[0, cut_off - 1] + '...'
      end
      working_full_name
    else
      "#{player.first_name} #{player.last_name}"
    end
  end

  def current_contract
    self.contracts.where('starts_at <= ? AND signed = ? AND team_id = ?', Date.today, true, team.id).order(starts_at: :desc).first
  end

  def get_squad_position_from_players_playing_position
     SquadPosition.find_by(long_name: player.playing_position)
  end

  def full_name_with_team_name
    "#{player.first_name} #{player.last_name} (#{team.title})"
  end
end
