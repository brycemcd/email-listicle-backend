require 'dotenv'
Dotenv.load
Bundler.require

require 'grape'
require_relative "lib/base"
require_relative "async/base"

module EmailListicle
  class API < Grape::API
    version 'v1', using: :path
    format :json
    prefix :api

    resource :cards do
      desc "fetches unlabeled cards from the ToDo list @ Trello"
      get :unlabeled do
        TrelloInterface.unlabeled_cards_in_list
      end

      desc "Fetches cards that are in the TODO list and labeled"
      get :unread do
        TrelloInterface.labeled_cards_in_list
      end

      put :label do
        TrelloInterface.label_card(card_id: params[:card_id],
                                   label_color:  params[:label_color])
      end
    end

    resource :email_links do
      desc "Lists un-seen links"
      get :all do
        EmailLink.undecided
      end

      desc "fetches unread stories"
      get :unread do
        EmailLink.unread
      end

      desc "Parse and store links from an email"
      post do
        StoreLinksFromEmailWorker.perform_async(params['mandrill_events'])
        {status: :ok}
      end

      desc "adds link id to reading list"
      post :mark_for_read do
        AddLinkToReadingListWorker.perform_async(params[:id])
      end

      desc "adds link id to not going to read"
      post :mark_for_reject do
        RejectLinkFromReadingListWorker.perform_async(params[:id])
      end
    end
  end
end
