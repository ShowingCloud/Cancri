class PushJob < ApplicationJob
  queue_as :notifications

  def perform(hash)
    ActionCable.server.broadcast 'notification_channel', message: hash
  end

end