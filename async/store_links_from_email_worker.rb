class StoreLinksFromEmailWorker
  include Sidekiq::Worker

  def perform(json_string)
    create_s3_object(json_string)
    msgs = JSON.parse(json_string)

    msgs.each do |json|
      ProcessLinksFromEmailWorker.perform_async(json)
    end
  end

  def create_s3_object(json_string)
    bucket = Aws::S3::Bucket.new("bme-listicle")
    bucket.put_object({
      acl: "public-read",
      body: json_string,
      key: "inbound-emails/#{Time.now.iso8601}.json",
      storage_class: "STANDARD_IA"
    })
  end
end
