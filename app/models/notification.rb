class Notification < ApplicationRecord
  belongs_to :user

  # 队长邀请队员 审核结果 拒绝/统一申请 申请加入队伍
  scope :unread, -> { where(read: false) }
  after_create :realtime_push_to_client

  private

  def realtime_push_to_client
    if user
      hash = notify_hash
      hash[:count] = self.user.notifications.unread.count
      MessageBus.publish "/channel/#{self.user.private_token}", hash
    end
  end

  def notify_hash
    {
        content: self.content[0, 30],
        time: Time.now.try(:strftime, '%Y-%m-%d %H:%M:%S')
    }
  end

end
