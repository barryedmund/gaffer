class TeamPlayer < ActiveRecord::Base
  belongs_to :team
  belongs_to :player
  belongs_to :squad_position
  validates :squad_position_id, presence: true

  def full_name
    "#{player.first_name} #{player.last_name}"
  end
end
