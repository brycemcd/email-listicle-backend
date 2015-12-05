Aws.config.update({
  region: 'us-west-2',
  credentials: Aws::Credentials.new(ENV["AWS_KEY_ID"],
                                    ENV["AWS_SECRET"]),
})

# init a client the other classes can inherit
Aws::S3::Client.new(region: "us-west-2")
