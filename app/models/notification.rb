class Notification < ApplicationRecord
  belongs_to :user

  scope :unread, -> { where(read: false) }
  after_save :realtime_push_to_client

  private

  def realtime_push_to_client
    if user
      hash = notify_hash
      hash[:count] = '7'
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
