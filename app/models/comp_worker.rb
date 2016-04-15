class CompWorker < ActiveRecord::Base
  belongs_to :user
  belongs_to :user_profile, foreign_key: :user_id
  belongs_to :competition
  validates :user_id, presence: true
  validates :competition_id, presence: true

end