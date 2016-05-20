web: bundle exec rackup --port $PORT
worker: bundle exec sidekiq -r ./async/base.rb -c 10
