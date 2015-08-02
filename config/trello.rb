require 'trello'
Trello.configure do |configure|
  configure.member_token = ENV['TRELLO_MEMBER_TOKEN']
  configure.developer_public_key = ENV['TRELLO_DEVELOPER_PUBLIC_KEY']
end
