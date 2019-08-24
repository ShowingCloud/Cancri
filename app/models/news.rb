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
  mount_uploader :cover, CoverUploader

  private

  def set_district
    if district_id == nil
      self.district_id=0
    end
  end
end
