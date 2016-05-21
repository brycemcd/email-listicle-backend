require 'sidekiq/api'

def get_failed_jobids
  rs = Sidekiq::RetrySet.new
  rs.map(&:jid)
end

def retry_job(jid)
  job = Sidekiq::RetrySet.new.find_job(jid)
  job.retry
end
