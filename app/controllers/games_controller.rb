class GamesController < ApplicationController
  def index
    @games = Game.all
  end

  def create
    @game = Game.create!(sb: 10, bb: 20)
    @games = Game.all
    render :index
  end

  def show
    @game = Game.find(params[:id])
    @hand = @game.hands.last
  end
end
