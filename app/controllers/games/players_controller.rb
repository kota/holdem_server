class Games::PlayersController < ApplicationController
  def create
    @game = Game.find(params[:game_id])
    @player = @game.players.create!(user: @current_user, chip: 5000)
    redirect_to game_url(id: @game.id)
  end
end
