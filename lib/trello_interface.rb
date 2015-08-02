require_relative "../config/trello"

class TrelloInterface
  def self.add_to_todo(el)
    card = Trello::Card.create(list_id: ENV['TRELLO_LIST_ID'],
                               name: el.title,
                               pos: 'bottom')
    card.add_attachment(el.url)
  end
end
