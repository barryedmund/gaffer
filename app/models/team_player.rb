class TeamPlayer < ActiveRecord::Base
  belongs_to :team
  belongs_to :player
  belongs_to :squad_position
  has_many :contracts, :dependent => :destroy
  validates :squad_position_id, presence: true
  accepts_nested_attributes_for :contracts, :allow_destroy => :true

  def full_name
    "#{player.first_name} #{player.last_name}"
  end

  def current_contract
    self.contracts.where('starts_at <= ? AND ends_at >= ?', Date.today, Date.today).order(starts_at: :desc).first
  end
end
