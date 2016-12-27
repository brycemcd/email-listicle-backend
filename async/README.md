# Asynchronous Tasks Overview

The async tasks in this project are built as a pipeline of various
experiments. The goal is to handle notifications of incoming emails,
extract interesting links in those emails and then prepare them for
consideration of the human user in the UI.

At some point in the future, this pipeline should be able to train
models, automatically tag category of content from the link and build a
confidence score of if the link will be accepted by the user.

The pipeline is meant to be as event driven as possible and it's
certainly a work in progress.

## Pipeline

[Email sent] => Received by AWS SES (all-mail-copy rule) =>
[Notify news-email SNS topic, Copy email content to S3 (bme-listicle bucket)] =>
[save notification to ES /sns_notifications/news-email,
 post to async app /email_links] => Kick Off Async Workers

### Update 2016-12-04

I've begun experimenting with using the new AWS Step Functions to
manage this pipeline. The step functions appear to be designed to handle
this workflow whereas I feel I've shoehorned a series of async processes
together to fit the needs of this application. The approach of
shoehorning has been okay, but yielded frequent events that fail
midstream with no notification (I realize this is my own laziness).

The approach here is to start at the end and work forward. I'll begin by
making an API endpoint for each async process and then call the API
endpoint from the step function. Once this is complete I can assess how
well the step functions work compared to the series of sidekiq
tasks.

Migration to API endpoints:

+ [ ] StoreLinksFromEmailWorker
+ [ ] ProcessLinksFromEmailWorker
+ [ ] FeatureEngineeringBatchWorker
+ [ ] LinkFilter
  + [x] Count Words in Title
  + [ ] `check_and_reject`

### Async Worker Flow

StoreLinksFromEmailWorker => ProcessLinksFromEmailWorker => FeatureEngineeringBatchWorker =>
LinkFilter

### StoreLinksFromEmailWorker

Parses message content from email notification message (SNS) and calls
`ProcessLinksFromEmailWorker`.

### ProcessLinksFromEmailWorker

Parses raw email message content, extracts all links and saves them as
`EmailLink` documents in ElasticSearch.

### FeatureEngineeringBatchWorker

Picks up all unengineered `EmailLink`s and puts them into a `LinkFilter`
queue

### LinkFilter

Sets the value for the number of words in the title and then runs
`check_and_reject` method on the `EmailLink` instance to execute the
autorejection code.

## Post Pipeline

After LinkFilter, the user can accept/reject the link for reading. Once
accepted, a card is added to Trello in the TODO list. In the early days
of this app, Trello served as the UI layer for accepted links. I still
revert to this layer from time to time when something in the API layer
is broken and I don't create urgency to fix it.

After a link is accepted, the user labels the article with one of three
labels.

After the link is labeled, it's in the "ready for read" queue. The user
moves it to "doing" to start reading the article.

When done reading, the user moves it to done in Trello. There's no UI
element to move the card from doing to done at this time.
