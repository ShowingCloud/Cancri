class Team < ApplicationRecord
  belongs_to :user
  belongs_to :event
  belongs_to :district
  has_many :team_user_ships, :dependent => :destroy
  has_many :users, through: :team_user_ship
  has_many :invites
  mount_uploader :cover, CoverUploader

  GROUP = {primary: 1, middle: 2, junior: 3, high: 4}
  validates :name, presence: true, length: {in: 2..5}, format: {with: /\A[\u4e00-\u9fa5_a-zA-Z0-9]+\Z/i, message: '队伍名称只能包含中文、数字、字母、下划线'}, uniqueness: {scope: :event_id, message: '同一个项目的队伍名称不能重复'}
  validates :user_id, presence: true
  validates :group, presence: true, length: {is: 1}
  validates :event_id, presence: true, uniqueness: {scope: :user_id, message: '一个用户不能报名一个项目两次'}
  validates :teacher, presence: true, format: {with: /\A[\u4e00-\u9fa5]+\Z/i, message: '教师名称只能包含中文'}
  validates :team_code, length: {in: 4..6}, allow_blank: true
  after_create :create_identifier

  protected
  def create_identifier
    unless identifier.present?
      case group
        when 1 then
          identity = 'X'
        when 2 then
          identity = 'Z'
        when 3 then
          identity = 'C'
        else
          identity = 'G'
      end
      self.identifier = ('0000000'+(id+128).to_s).each_byte do |c|
        if c != 48
          identity.concat((c.to_i + 16).chr)
        else
          identity.concat('O')
        end
      end
    end
  end
end
