web: bundle exec rackup --port $PORT
worker: bundle exec sidekiq -r ./async/store_links_from_email_worker.rb
