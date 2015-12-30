class GamesController < ApplicationController
  def index
    @games = Game.all
  end

  def create
    @game = Game.create!(sb: 50, bb: 100)
    @games = Game.all
    render :index
  end

  def show
    @game = Game.find(params[:id])
    @hand = @game.hands.last
  end
end
