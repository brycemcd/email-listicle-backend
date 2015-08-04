require 'dotenv'
Dotenv.load
Bundler.require

require 'grape'
require_relative "lib/base"

module EmailListicle
  class API < Grape::API
    version 'v1', using: :path
    format :json
    prefix :api

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
        msgs = JSON.parse(params['mandrill_events'])

        msgs.each do |json|
          pl = ParseEmailLinks.new(json['msg']['html'],
                                   json['msg']['subject'])
          pl.save_parsed_links
        end
      end

      desc "adds link id to reading list"
      post :mark_for_read do
        el = EmailLink.add_to_reading_list(params[:id])
        TrelloInterface.add_to_todo(el)
      end

      desc "adds link id to not going to read"
      post :mark_for_reject do
        EmailLink.reject_from_reading_list(params[:id])
      end
    end
  end
end
