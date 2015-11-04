class League < ActiveRecord::Base
	has_many :teams, dependent: :destroy
	belongs_to :user
	validates :user_id, presence: true
end