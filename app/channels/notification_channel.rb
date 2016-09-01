class NotificationChannel < ApplicationCable::Channel
  def subscribed
    stop_all_streams
    stream_from "notification_channel"
  end

  def unsubscribed
    stop_all_streams
  end
end
