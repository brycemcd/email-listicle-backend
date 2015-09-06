require_relative "../config/trello"

# NOTE: YUCK - monkey patch
module Trello
  class List < BasicData
    def self.list_with_cards(list_id, params)
      ret = client.get("/lists/#{list_id}/cards", params)
      JSON.parse(ret)
    end
  end
end

class TrelloInterface
  def self.add_to_todo(el)
    card = Trello::Card.create(list_id: ENV['TRELLO_LIST_ID'],
                               name: el.title,
                               pos: 'bottom')
    card.add_attachment(el.url)
  end

  def self.all_cards_in_list(list_id: ENV['TRELLO_LIST_ID'])
    Trello::List.list_with_cards(list_id, attachments: true)
  end

  def self.labeled_cards_in_list(list_id: ENV['TRELLO_LIST_ID'])
    cards = all_cards_in_list(list_id: list_id)
    cards.select { |card| !card["labels"].empty? }
  end

  def self.unlabeled_cards_in_list(list_id: ENV['TRELLO_LIST_ID'])
    cards = all_cards_in_list(list_id: list_id)
    cards.select { |card| card["labels"].empty? }
  end

  def self.label_card(card_id: nil, label_color: nil)
    Trello::Card.find(card_id).add_label(label_color)
  end
end
