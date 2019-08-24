class UserHacker < ApplicationRecord
  belongs_to :user
  belongs_to :user_role
  PARTAKE = {children: 1, parent: 2, parental: 3} # 1:孩子, 2:家长, 3:亲子
  validates :situation, presence: true, inclusion: [1, 2]
  validates :partake, presence: true, inclusion: [1, 2, 3]
  validates :create_way, presence: true, inclusion: [1, 2, 3, 4]
  validates :create_date, :active_weekly, presence: true
  validates :square, numericality: {greater_than: 0}
  validates :create_with, presence: true, if: :create_way_1

  protected
  def create_way_1
    create_way.to_i != 1
  end
end
