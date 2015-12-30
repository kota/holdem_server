class Games::PlayersController < ApplicationController
  def create
    @game = Game.find(params[:game_id])

    #TODO seat position
    @player = @game.players.create!(user: @current_user, chip: 10000)
    redirect_to game_url(id: @game.id)
  end
end
