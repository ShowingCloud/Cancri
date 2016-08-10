class PushJob
  include Sidekiq::Worker
  sidekiq_options queue: 'notifications'

  def perform(token, hash)
    MessageBus.publish "/channel/#{token}", hash
  end

end