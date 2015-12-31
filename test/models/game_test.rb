require 'test_helper'

class GameTest < ActiveSupport::TestCase
  test "can start hand" do
    game = Game.new(sb: 10, bb: 20, players: [players(:ivey), players(:hellmuth)])
    assert_nothing_raised { game.start_hand! }
  end

  test "can't start hand with only one player" do
    game = Game.new(sb: 10, bb: 20, players: [players(:ivey)])
    assert_raises(Exception) { game.start_hand! }
  end

end
