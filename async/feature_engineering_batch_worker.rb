class FeatureEngineeringBatchWorker
  include Sidekiq::Worker

  def perform
    els = EmailLink.unengineered
    els.each do |el|
      LinkFilter.perform_async(el.id)
    end
  end
end
