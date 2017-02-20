class News < ApplicationRecord
  belongs_to :admin
  belongs_to :district
  before_validation :set_district
  validates :name, presence: true, uniqueness: true, length: {maximum: 60}
  validates :news_type, presence: true
  validates :content, presence: true
  validates :admin_id, presence: true
  validates :desc, presence: true
  validates :cover, presence: true
  after_validation :check_apply_date
  mount_uploader :cover, CoverUploader

  private

  def set_district
    if district_id == nil
      self.district_id=0
    end
  end

  def check_apply_datetime
    new_type = NewsType.where(name: '志愿者招聘').take
    if new_type.present? && new_types.split(',').include?(new_type.id)
      if apply_start_time.blank? && apply_end_time.present?
        if apply_start_time > apply_end_time
          errors[:apply_start_time] << '起始时间不能晚于结束时间!'
        end
      else
        errors[:apply_start_time] << '类型为志愿者招募时，招募起始时间必填!'
      end
    else
      self.apply_start_time = nil
      self.apply_end_time = nil
    end
  end
end
