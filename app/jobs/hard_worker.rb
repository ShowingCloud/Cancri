class HardWorker
  include Sidekiq::Worker

  def perform(name)
    puts name
  end
end