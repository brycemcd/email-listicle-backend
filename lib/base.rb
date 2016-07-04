require 'dotenv'
Dotenv.load
Bundler.require

require_relative '../config/bugsnag'

require_relative 'fetch_article_content'
require_relative 'parse_email_html'
require_relative 'email_link'
require_relative 'email_link_similarity'
require_relative 'email_link_rejection'
require_relative 'es_client'
require_relative 'trello_interface'
require_relative 'raw_email/parse'
require_relative 'sns_request'
