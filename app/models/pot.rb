class Pot < ActiveRecord::Base
  belongs_to :hand
  has_many :players

  def winners
    if self.players.active.count == 1
      return [self.players.active[0]]
    elsif self.hand.round == 'showdown' && players = winners_at_showdown
      return players
    end
    nil
  end

  def winners_at_showdown
    players_hands = self.players.active.map do |player|
      [player, PokerHand.new("#{player.hole_cards} #{self.hand.community_cards}")]
    end.sort_by { |player_hand| player_hand[1] }
    players_hands.select { |player_hand| player_hand[1] == players_hands.last[1] }.map(&:first)
  end

end
