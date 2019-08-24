class PushJob < ApplicationJob
  queue_as :notifications

  def perform(hash)
    ActionCable.server.broadcast "notifications_channel_#{hash[:user_id]}", message: hash
  end

end