class CreateNotificationJob < ApplicationJob
  queue_as :notifications

  def perform(notification_hash)
    if notification_hash[:user_id].present? && notification_hash[:content].present? && notification_hash[:message_type].present?
      Notification.create(notification_hash)
    else
      puts "Warning:notification#{notification_hash} created fail ===================================="
    end
  end
end