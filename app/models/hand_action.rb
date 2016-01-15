class HandAction < ActiveRecord::Base
  belongs_to :hand
  belongs_to :player

  def sb!
    hand.add_to_pot!(hand.sb)
    player.bet!(hand.sb)
    self.bet_amount = hand.sb
    self.action_type = 'bet/raise'
    self.round = 'preflop'
    save!
  end

  def bb!
    hand.add_to_pot!(hand.bb)
    player.bet!(hand.bb)
    self.bet_amount = hand.bb
    self.action_type = 'bet/raise'
    self.round = 'preflop'
    save!
  end
end
