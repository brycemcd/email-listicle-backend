class FeatureEngineeringBatchWorker
  include Sidekiq::Worker

  def perform
    els = EmailLink.unengineered
    els.each do |el|
      FeatureEngineeringWorker.perform_async(el.id)
    end
  end
end
