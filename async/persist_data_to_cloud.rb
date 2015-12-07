class PersistDataToCloud
  include Sidekiq::Worker

  def perform(data: nil, bucket: nil, key: nil)
    bucket = Aws::S3::Bucket.new(bucket)
    bucket.put_object({
      acl: "public-read",
      body: data.to_s,
      key: key,
      storage_class: "STANDARD_IA"
    })
  end

end
