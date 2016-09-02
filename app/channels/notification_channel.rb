class NotificationChannel < ApplicationCable::Channel
  def subscribed
    stop_all_streams
    if self.current_user
      stream_from "notifications_channel_#{self.current_user}"
    end
  end

  def unsubscribed
    stop_all_streams
  end
end
