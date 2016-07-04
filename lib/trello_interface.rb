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
    card = Trello::Card.create(list_id: ENV['TRELLO_TODO_LIST_ID'],
                               name: el.title,
                               pos: 'bottom')
    card.add_attachment(el.url)
  end

  def self.all_cards_in_list(list_id: ENV['TRELLO_TODO_LIST_ID'])
    Trello::List.list_with_cards(list_id, attachments: true)
  end

  def self.labeled_cards_in_list(list_id: ENV['TRELLO_TODO_LIST_ID'])
    cards = all_cards_in_list(list_id: list_id)
    cards.select { |card| !card["labels"].empty? }
  end

  def self.unlabeled_cards_in_list(list_id: ENV['TRELLO_TODO_LIST_ID'])
    cards = all_cards_in_list(list_id: list_id)
    cards.select { |card| card["labels"].empty? }
  end

  def self.label_card(card_id: nil, label_color: nil)
    color_id = label_from_color(label_color)
    Trello::Card.find(card_id).add_label(color_id)
  end

  def self.move_card_to_list(card_id: nil, list_id: nil)
    card = Trello::Card.find(card_id)
    listed = card.move_to_list(list_id)
    move_card_position_on_list(card_id: card_id)
    listed
  end

  def self.move_card_position_on_list(card_id: nil, position: :top)
    card = Trello::Card.find(card_id)
    card.pos = :top
    card.save
  end

  def self.close_card(card_id: nil)
    card = Trello::Card.find(card_id)
    card.closed = true
    card.save
  end

  def self.vote_on_card(card_id: nil, voting_member: ENV['TRELLO_USER_ID'])
    uri = "/cards/#{card_id}/membersVoted"
    Trello.client.post(uri, {value: voting_member})
  end

  def self.label_from_color(color)
    colors = { 'orange' => '5516b206664ce8ff30c2bd0b',
               'yellow' => '5516b206664ce8ff30c2bd0a',
               'green'  => '5516b206664ce8ff30c2bd09',
    }

    Trello::Label.find(colors[color])
  end
end
