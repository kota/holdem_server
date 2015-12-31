require 'test_helper'

class HandTest < ActiveSupport::TestCase
  
  def setup
    @ivey = players(:ivey)
    @hellmuth = players(:hellmuth)
    @daniel = players(:daniel)

    @game = Game.new(sb: 10, bb: 20)
  end

  test "sb and bb bet blinds" do
    @game.players = [@ivey, @hellmuth, @daniel]
    @game.current_button_player = @daniel
    @game.save!

    hand = @game.start_hand!
    assert_equal(@game.current_button_player, @ivey)
    assert_equal(@game.sb + @game.bb, hand.pot)
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
    assert_equal(@game.sb + @game.bb, hand.pot)
    assert_equal(@game.sb, @ivey.current_bet)
    assert_equal(@game.bb, @hellmuth.current_bet)
  end

end
