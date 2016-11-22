class CompetitionSchedule < ApplicationRecord
  default_scope { order('start_time ASC') }
  belongs_to :competition
  validates :name, :competition_id, :start_time, presence: true
  after_validation :check_time
  private
  def check_time
    if end_time.present? && end_time.is_a?(Time) && (end_time < start_time)
      errors[:end_time] << '不能早于开始时间'
    end
  end
end
