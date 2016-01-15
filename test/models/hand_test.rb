require 'test_helper'

class HandTest < ActiveSupport::TestCase

  def setup
    @ivey = players(:ivey)
    @hellmuth = players(:hellmuth)
    @daniel = players(:daniel)

    @game = Game.new(sb: 10, bb: 20)
  end

  def setup_hand
    @hand = @game.start_hand!
    @hand.flop = PokerHand.new("Ah Ks Qc").cards.map(&:to_db).join(' ')
    @hand.turn = Card.new("2h").to_db
    @hand.river = Card.new("3s").to_db
    @hand.save!
  end

  def setup_showdown_hand
    self.setup_hand
    @hand.round = 'showdown'
    @hand.save!
  end

  test "sb and bb bet blinds" do
    @game.players = [@ivey, @hellmuth, @daniel]
    @game.current_button_player = @daniel
    @game.save!

    hand = @game.start_hand!
    assert_equal(@game.current_button_player, @ivey)
    assert_equal(@game.sb + @game.bb, hand.active_pot.amount)
    assert_equal(@game.sb, @hellmuth.current_bet)
    assert_equal(@game.bb, @daniel.current_bet)
  end

  test "sb == button if heads up" do
    @game.players = [@ivey, @hellmuth]
    @game.current_button_player = @hellmuth
    @game.save!

    hand = @game.start_hand!
    assert_equal(@game.current_button_player, @ivey)
    assert_equal(hand.sb_player, @ivey)
    assert_equal(@game.sb + @game.bb, hand.active_pot.amount)
    assert_equal(@game.sb, @ivey.current_bet)
    assert_equal(@game.bb, @hellmuth.current_bet)
  end

  test "stronger hand wins" do
    @game.players = [@ivey, @hellmuth]
    self.setup_showdown_hand

    pot = @hand.active_pot.amount

    @ivey.hole_cards = PokerHand.new("As 6c").cards.map(&:to_db).join(' ')
    @ivey.save!
    @hellmuth.hole_cards = PokerHand.new("Ks 6c").cards.map(&:to_db).join(' ')
    @hellmuth.save!

    assert_equal(1, @hand.active_pot.winners.count)
    assert_equal(@ivey, @hand.active_pot.winners.first)

    assert_difference -> { Player.find(@ivey.id).chip }, pot do
      @hand.finish!
    end
  end

  test "equal hands chops" do
    @game.players = [@ivey, @hellmuth]
    self.setup_showdown_hand

    pot = @hand.active_pot.amount

    @ivey.hole_cards = PokerHand.new("As 6c").cards.map(&:to_db).join(' ')
    @ivey.save!
    @hellmuth.hole_cards = PokerHand.new("Ac 6d").cards.map(&:to_db).join(' ')
    @hellmuth.save!

    assert_equal(2, @hand.active_pot.winners.count)

    assert_difference -> { Player.find(@ivey.id).chip }, pot/2 do
      @hand.finish!
    end
  end

  test "fold out other players to win" do
    @game.players = [@ivey, @hellmuth, @daniel]
    @game.current_button_player = @ivey
    @game.save!

    self.setup_hand

    @hand.add_action(HandAction.new(action_type: 'fold', player: @hellmuth, bet_amount: nil))
    @hand.add_action(HandAction.new(action_type: 'fold', player: @daniel, bet_amount: nil))

    assert_equal(1, @hand.active_pot.winners.count)
    assert_equal(@ivey, @hand.active_pot.winners.first)
  end
end
