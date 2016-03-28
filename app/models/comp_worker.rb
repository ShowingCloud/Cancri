class CompWorker < ActiveRecord::Base
  validates :user_id, presence: true
  validates :competition_id, presence: true

end