#TODO Move to appropriate lib file
#Override holdem gem's class
class Card
  def to_db
    "#{rank}#{suit}"
  end

  def rank_str_for_image
    return rank if rank.to_i > 0
    return {T: '10', J: 'jack', Q: 'queen', K: 'king', A: 'ace'}[rank.to_sym]
  end

  def suit_str_for_image
    {s: 'spades', d: 'diamonds', h: 'hearts', c: 'clubs'}[suit.to_sym]
  end

  def self.to_image_html(card_str)
    card = Card.new(card_str)
    "<img style='width:5%' src='/images/cards/#{card.rank_str_for_image}_of_#{card.suit_str_for_image}.png' />"
  end
end

class Hand < ActiveRecord::Base
  belongs_to :game
  has_many :players
  belongs_to :action_player, class_name: "Player"
  has_many :hand_actions

  after_create :start

  def position_for(player)
    utg_index = self.players.index(utg_player)
    player_index = self.players.index(player)
    player_index += self.players.count - 1 if player_index < utg_index
    player_index - utg_index
  end

  def sb_player
    button_player = self.game.current_button_player
    self.players.size == 2 ? button_player : player_next_to(button_player) 
  end

  def bb_player
    self.player_next_to(sb_player)
  end

  def utg_player
    self.player_next_to(bb_player)
  end

  def assign_positions
    def next_player(players, origin_player)
      index = players.index(origin_player)
      index += 1
      index %= players.count
      players[index]
    end

    ordered_players = self.players.order(:position).to_a
    button = self.game.current_button_player

    position = 0

    utg = utg_player
    utg.position = position
    utg.save!
  
    player = utg
    while (player = next_player(ordered_players, player)) != utg
      position += 1
      player.position = position 
      player.save!
    end
  end

  def start
    deck = Deck.new
    deck.shuffle!

    self.players.each(&:prepare_for_new_hand!)

    self.assign_positions

    self.players.reload.each do |player|
      player.hole_cards = deck.deal(2).map(&:to_db).join(' ')
      player.save!
    end

    self.pot ||= 0
    self.hand_actions.build(player: sb_player).sb!
    self.hand_actions.build(player: bb_player).bb!

    self.flop = deck.deal(3).map(&:to_db).join(' ')
    self.turn = deck.deal(1).map(&:to_db).join(' ')
    self.river = deck.deal(1).map(&:to_db).join(' ')
    self.action_player = utg_player
    self.round = 'preflop'
    save!
  end

  def add_action(action)
    raise "It's not your turn #{action.player.user.name}, its #{action_player.user.name}'s" if action.player.id != self.action_player.id

    self.pot ||= 0
    action.round = self.round

    max_bet = round_actions.map{ |action| action.bet_amount || 0 }.max || 0
    to_pot = 0


    next_action_player = player_next_to(self.action_player)

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
      action.player.state = 'folded'
    end

    if to_pot > 0
      self.pot += to_pot
      action.player.chip -= to_pot
    end

    action.player.save!
    
    self.hand_actions << action

    if winners != nil
      finish!
      return
    end

    if round_finished?
      self.action_player = self.players.active.order(:position).reload.first
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

    self.action_player = next_action_player
    save!
  end

  def finish!
    raise 'Not finished yet' unless win_players = winners
    chip_won = self.pot / winners.count
    win_players.each do |winner|
      winner.chip += chip_won
      winner.save!
    end
  end

  def winner?(player)
  end

  def winners
    if self.players.active.count == 1
      return [self.players.active[0]]
    elsif self.round == 'showdown' && players = winners_at_showdown
      return players
    end
    nil
  end

  def winners_at_showdown 
    players_hands = self.players.active.map do |player|
      [player, PokerHand.new("#{player.hole_cards} #{self.community_cards}")]
    end.sort_by { |player_hand| player_hand[1] }
    players_hands.select { |player_hand| player_hand[1] == players_hands.last[1] }.map(&:first)
  end

  def round_finished?
    # drop(2) to remove sb,bb actions if preflop
    actions_so_far = self.round == 'preflop' ? round_actions.drop(2) : round_actions
    all_players_done = actions_so_far.map { |action| action.player.id }.uniq.size == self.players.active.reload.size
    all_betting_same_amount = self.players.active.map do |player|
      round_actions.where(player_id: player.id).maximum(:bet_amount)
    end.uniq.size == 1
    all_players_done && all_betting_same_amount
  end

  def finished?
    winners != nil
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
    active_players = self.players.active.order(:position).to_a

    index = active_players.index { |player| player.id == origin_player.id }
    next_index = index + 1
    next_index %= active_players.count
    active_players[next_index]
  end
end
