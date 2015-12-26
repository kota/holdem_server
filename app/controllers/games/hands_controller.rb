class Games::HandsController < ApplicationController
  def create
    @game = Game.find(params[:game_id])
    @hand = @game.hands.create(players: @game.players)

    @hand.players.each do |player| 
      ActionCable.server.broadcast "games:#{@hand.game.id}:#{player.user.id}",
        hand: Games::HandActionsController.render(partial: 'games/hands/show', locals: { hand: @hand, game: @game, current_user: player.user }), my_action: @hand.action_player.id == player.id
    end

    head :no_content
  end
end
