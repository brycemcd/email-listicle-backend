require_relative "../config/trello"

class TrelloInterface
  def self.add_to_todo(el)
    card = Trello::Card.create(list_id: ENV['TRELLO_LIST_ID'],
                               name: el.title,
                               pos: 'bottom')
    card.add_attachment(el.url)
  end

  def self.all_cards_in_list(list_id: ENV['TRELLO_LIST_ID'])
    cards = Trello::List.find(list_id).cards
  end

  def self.unlabeled_cards_in_list(list_id: ENV['TRELLO_LIST_ID'])
    @cards ||= all_cards_in_list(list_id: list_id)
    @cards.select { |card| card.card_labels.empty? }
  end

  def self.label_card(card_id: nil, label_color: nil)
    Trello::Card.find(card_id).add_label(label_color)
  end
end
