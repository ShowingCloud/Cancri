class NotificationChannel < ApplicationCable::Channel
  def subscribed
    stop_all_streams
    if self.current_user_guid
      stream_from "notifications_channel_#{self.current_user_guid}"
    end
  end

  def unsubscribed
    stop_all_streams
  end
end
