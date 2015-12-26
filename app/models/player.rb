class Player < ActiveRecord::Base
  belongs_to :user
  belongs_to :game
  belongs_to :hand
  has_many :actions

  scope :active, -> { where(folded: false) }
  default_scope -> { order(:id) }

  def prepare_for_new_hand
    self.hole_cards = nil
    self.folded = false
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

  def to_s(show_hole_cards=false)
    str = "#{self.user.name} (#{self.chip})"
    str += " #{self.hole_cards}" if show_hole_cards || self.hand.finished?
    str += " Win #{self.hand.pot}" if self.hand.winner != nil && self.hand.winner.id == self.id
    str += " #{current_bet}" unless self.hand.finished?
    str += " *" if turn? && !self.hand.finished?
    str
  end

  def to_s_for_owner_user
    to_s(true)
  end

end
