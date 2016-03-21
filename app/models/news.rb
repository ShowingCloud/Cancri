class News < ApplicationRecord
  belongs_to :admin

  validates :name, presence: true, uniqueness: true, length: {maximum: 60}
  validates :news_type, presence: true
  validates :content, presence: true
  # validates :admin_id, presence: true
  NEWS_TYPE ={cp_apply: 1, cp_score: 2, vol_recruit: 3, act_apply: 4, act_report: 5}
end
