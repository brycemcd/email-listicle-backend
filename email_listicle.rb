require 'httparty'

#response = HTTParty.get('http://ng-newsletter.us6.list-manage.com/track/click?u=86d6f14c7cc955128485e3b8e&id=8cabdb99e9&e=c2ad06fd2c')
#response = HTTParty.get('http://rubyweekly.us1.list-manage.com/track/click?u=0618f6a79d6bb9675f313ceb2&id=1bb06d3aa9&e=59c980d683')
response = HTTParty.get('http://rubyweekly.us1.list-manage.com/track/click?u=0618f6a79d6bb9675f313ceb2&id=9765b88476&e=59c980d683')

puts response.code
puts response.headers.inspect
puts response.body

