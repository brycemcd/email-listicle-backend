require 'dotenv'
Dotenv.load
Bundler.require

require_relative "../lib/base"

require 'sidekiq'
require_relative "store_links_from_email_worker"
require_relative "process_links_from_email_worker"
