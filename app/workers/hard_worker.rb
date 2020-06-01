class HardWorker
  include Sidekiq::Worker

  def perform(name, count)
    puts "I'm a hard worker, working... #{DateTime.now}"

  end
end