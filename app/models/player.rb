class Player < ActiveRecord::Base
  belongs_to :user
  belongs_to :game
  belongs_to :hand
  has_many :actions

  scope :active, -> { where.not(state: ['folded','busted']) }
  scope :not_busted, -> { where.not(state: 'busted') }
  default_scope -> { order(:id) }

  def prepare_for_new_hand!
    self.hole_cards = nil
    self.state = 'ingame'
    save!
  end

  def bet!(amount)
    #TODO all-in
    self.chip -= amount
    save!
    amount
  end

  def turn?
    self.hand.action_player.id == self.id
  end

  def current_bet
    if last_action = self.hand.round_actions.where(player_id: self.id).last
      return last_action.bet_amount
    end
    0
  end

  def hole_card_image_html
    cards = self.hole_cards.split(' ')
    "#{Card.to_image_html(cards[0])}#{Card.to_image_html(cards[1])}" 
  end

  def to_s(show_hole_cards=false)
    button_notation = self.hand.game.current_button_player.id == self.id ? " (D) " : ""
    str = "#{self.user.name}#{button_notation}(#{self.chip})"
    str += " #{self.hole_card_image_html}" if show_hole_cards || self.hand.finished?
    str += " Win #{self.hand.pot}" if self.hand.winner != nil && self.hand.winner.id == self.id
    str += " #{current_bet}" unless self.hand.finished?
    str += " *" if turn? && !self.hand.finished?
    str
  end

  def to_s_for_owner_user
    to_s(true)
  end

end
