require 'dotenv'
Dotenv.load
Bundler.require

require 'grape'
require_relative "lib/base"
require_relative "async/base"

module EmailListicle
  class API < Grape::API
    version 'v1', using: :path
    prefix :api

    resource :cards do
      format :json

      desc "fetches unlabeled cards from the ToDo list @ Trello"
      get :unlabeled do
        TrelloInterface.unlabeled_cards_in_list
      end

      desc "Fetches cards that are in the TODO list and labeled"
      get :unread do
        TrelloInterface.labeled_cards_in_list.reverse
      end

      desc "Fetches cards that are in the DOING list"
      get :reading do
        TrelloInterface.all_cards_in_list(list_id: ENV['TRELLO_DOING_LIST_ID'])
      end

      desc "applies label color (like green, not a hash) to a card"
      put :label do
        TrelloInterface.label_card(card_id: params[:card_id],
                                   label_color:  params[:label_color])
      end

      desc "moves card from TODO to Doing list"
      put :move_card_to_doing do
        TrelloInterface.move_card_to_list(list_id: ENV['TRELLO_DOING_LIST_ID'],
                                          card_id: params[:card_id])
      end

      desc "moves card from Doing to Done list"
      put :move_card_to_done do
        TrelloInterface.move_card_to_list(list_id: ENV['TRELLO_DONE_LIST_ID'],
                                          card_id: params[:card_id])
      end

      desc "upvotes a card indicating the reader liked the article"
      params do
        requires :card_id, type: String, desc: "The Trello card id"
      end
      put :upvote_card do
        TrelloInterface.vote_on_card(card_id: params[:card_id]) &&
          Trello::Card.find(params[:card_id])
      end

      desc "archives card in Trello"
      delete :archive_card do
        TrelloInterface.close_card(card_id: params[:card_id])
      end
    end

    resource :email_links do

      desc "Parse and store links from an email"
      post do
        format 'text/plain'

        if headers['X-Amz-Sns-Message-Type']
          bd = ""
          request.body.each { |x| bd << x}
          json = JSON.parse(bd)
          SNSRequest.write_to_es( body: json, headers: headers, time: Time.now)
        else
          json = params
        end

        puts "headers"
        puts headers.to_yaml
        puts "json"
        puts json.to_yaml

        StoreLinksFromEmailWorker.perform_async(json)
        {status: :ok}
      end
    end

    resource :email_links do
      format :json

      desc "Lists un-seen links"
      get :all do
        EmailLink.undecided
      end

      desc "fetches unread stories"
      get :unread do
        EmailLink.unread
      end

      desc "adds link id to reading list"
      post :mark_for_read do
        AddLinkToReadingListWorker.perform_async(params[:id])
      end

      desc "adds link id to not going to read"
      post :mark_for_reject do
        RejectLinkFromReadingListWorker.perform_async(params[:id])
      end

      desc 'sets number of words in title attribute for an email link'
      params do
        requires :id, type: String, desc: 'ES id of email link'
      end
      put ':id/set_title_word_count' do
        begin
          # sigh - rather than returning a falsey value, an exception is raised
          el = EmailLink.find(params[:id])
          el.set_title_word_count
          el
        rescue Elasticsearch::Transport::Transport::Errors::NotFound
          status 404
        end
      end
    end
  end
end
