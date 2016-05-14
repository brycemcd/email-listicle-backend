#!/bin/bash
curl \
-H "x-amz-sns-message-type: Notification" \
-H "x-amz-sns-message-id: da41e39f-ea4d-435a-b922-c6aae3915ebe" \
-H "x-amz-sns-topic-arn: arn:aws:sns:us-west-2:123456789012:MyTopic" \
-H "x-amz-sns-subscription-arn: arn:aws:sns:us-west-2:123456789012:MyTopic:2bcfbf39-05c3-41de-beaa-fcfcc21c8f55" \
-H "Content-Length: 761" \
-H "Content-Type: text/plain; charset=UTF-8" \
-H "Host: ec2-50-17-44-49.compute-1.amazonaws.com" \
-H "Connection: Keep-Alive" \
-H "User-Agent: Amazon Simple Notification Service Agent" \
-d '{
  "Type" : "Notification",
  "MessageId" : "da41e39f-ea4d-435a-b922-c6aae3915ebe",
  "TopicArn" : "arn:aws:sns:us-west-2:123456789012:MyTopic",
  "Subject" : "test",
  "Message" : "test message",
  "Timestamp" : "2012-04-25T21:49:25.719Z",
  "SignatureVersion" : "1",
  "Signature" : "EXAMPLElDMXvB8r9R83tGoNn0ecwd5UjllzsvSvbItzfaMpN2nk5HVSw7XnOn/49IkxDKz8YrlH2qJXj2iZB0Zo2O71c4qQk1fMUDi3LGpij7RCW7AW9vYYsSqIKRnFS94ilu7NFhUzLiieYr4BKHpdTmdD6c0esKEYBpabxDSc=",
  "SigningCertURL" : "https://sns.us-west-2.amazonaws.com/SimpleNotificationService-f3ecfb7224c7233fe7bb5f59f96de52f.pem",
  "UnsubscribeURL" : "https://sns.us-west-2.amazonaws.com/?Action=Unsubscribe&SubscriptionArn=arn:aws:sns:us-west-2:123456789012:MyTopic:2bcfbf39-05c3-41de-beaa-fcfcc21c8f55"
}' \
http://10.1.2.102:8181/api/v1/email_links
