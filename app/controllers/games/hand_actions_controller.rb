class Games::HandActionsController < ApplicationController
  def create
    @hand = Hand.find(params[:hand_id])
    @game = @hand.game
    @player = @hand.players.where(user_id: @current_user.id).first
    @action = @hand.add_action(HandAction.new(action_type: params[:commit], player: @player, bet_amount: action_params[:bet_amount]))

    @hand.players.each do |player| 
      ActionCable.server.broadcast "games:#{@hand.game.id}:#{player.user.id}",
        hand: Games::HandsController.render(partial: 'games/hands/show', locals: { hand: @hand, game: @game, current_user: player.user }), my_action: @hand.action_player.id == player.id
    end

    head :no_content
  end

  private

  def action_params
    params.require(:hand_action).permit(:bet_amount)
  end

end
