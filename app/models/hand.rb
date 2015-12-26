#TODO Move to appropriate lib file
#Override holdem gem's class
class Card
  def to_db
    "#{rank}#{suit}"
  end
end

class Hand < ActiveRecord::Base
  belongs_to :game
  has_many :players
  belongs_to :action_player, class_name: "Player"
  belongs_to :button_player, class_name: "Player"
  has_many :hand_actions

  after_create :start

  def start
    deck = Deck.new
    deck.shuffle!

    #TODO seat position
    #TODO charge sb,bb
    self.players.each do |player|
      player.prepare_for_new_hand
      player.hole_cards = deck.deal(2).map(&:to_db).join(' ')
      player.save!
    end

    self.flop = deck.deal(3).map(&:to_db).join(' ')
    self.turn = deck.deal(1).map(&:to_db).join(' ')
    self.river = deck.deal(1).map(&:to_db).join(' ')
    self.action_player = self.players.first
    self.round = 'preflop'
    save!
  end

  def add_action(action)
    raise "It's not your turn" if action.player.id != self.action_player.id

    self.pot ||= 0
    action.round = self.round

    max_bet = round_actions.map(&:bet_amount).max || 0
    to_pot = 0

    case action.action_type
    when 'check/call'
      if max_bet == 0
        action.bet_amount = 0
      elsif last_action = round_actions.where(player_id: action.player.id).try(:last)
        
        last_bet = last_action.bet_amount
        action.bet_amount = max_bet
        to_pot = max_bet - last_bet 
      else
        action.bet_amount = max_bet
        to_pot = action.bet_amount
      end
      raise "You don't have enough chip" if action.player.chip < to_pot
    when 'bet/raise'
      if last_action = round_actions.where(player_id: action.player.id).try(:last)
        last_bet = last_action.bet_amount
        to_pot = action.bet_amount - last_bet
      else
        to_pot = action.bet_amount
      end
      raise "You don't have enough chip" if action.player.chip < to_pot
    when 'fold'
      action.player.folded = true
    end

    if to_pot > 0
      self.pot += to_pot
      action.player.chip -= to_pot
    end

    action.player.save!
    
    self.hand_actions << action

    if winner != nil
      finish!
      return
    end

    if round_finished?
      self.action_player = self.players.active.reload.first
      case self.round
      when 'preflop'
        self.round = 'flop'
      when 'flop'
        self.round = 'turn'
      when 'turn'
        self.round = 'river'
      when 'river'
        self.round = 'showdown'
        finish!
        return
      end
      save!
      return
    end

    self.action_player = player_next_to(self.action_player)
    save!
  end

  #TODO Chopped pot
  def finish!
    raise 'Not finished yet' unless win_player = winner
    win_player.chip += self.pot
    win_player.save!
  end

  def winner
    if self.players.active.count == 1
      return self.players.active[0]
    elsif self.round == 'showdown' && player = winner_at_showdown
      return player
    end
    nil
  end

  def winner_at_showdown 
    self.players.active.map do |player|
      [player, PokerHand.new("#{player.hole_cards} #{self.community_cards}")]
    end.sort_by { |player_hand| player_hand[1] }.last[0]
  end

  def round_finished?
    all_players_done = round_actions.map { |action| action.player.id }.uniq.size == self.players.active.reload.size
    all_betting_same_amount = self.players.active.map do |player|
      round_actions.where(player_id: player.id).maximum(:bet_amount)
    end.uniq.size == 1
    all_players_done && all_betting_same_amount
  end

  def finished?
    winner != nil
  end

  def round_actions
    self.hand_actions.where(round: self.round)
  end

  def community_cards
    case self.round
    when 'preflop'
      ""
    when 'flop'
      flop
    when 'turn'
      "#{flop} #{turn}"
    when 'river', 'showdown'
      "#{flop} #{turn} #{river}"
    end
  end

  def player_next_to(origin_player)
    players = self.players.active.to_a
    index = players.index { |player| player.id == origin_player.id }
    next_index = index + 1
    next_index %= players.count
    players[next_index]
  end

end
