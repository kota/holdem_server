class Game < ActiveRecord::Base
  has_many :players
  belongs_to :current_button_player, class_name: "Player"
  has_many :hands

  def start_hand!
    raise 'Not enough players' if self.players.size < 2

    if self.current_button_player
      self.current_button_player = self.player_next_to(self.current_button_player)
    else
      self.current_button_player = self.players.shuffle.first
    end
    save!

    self.hands.create(players: self.players, sb: self.sb, bb: self.bb)
  end

  #TODO handと重複している
  def player_next_to(origin_player)
    players = self.players.not_busted.to_a
    index = players.index { |player| player.id == origin_player.id }
    next_index = index + 1
    next_index %= players.count
    players[next_index]
  end
end
