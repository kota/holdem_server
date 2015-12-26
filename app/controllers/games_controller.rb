class GamesController < ApplicationController
  def index
    @games = Game.all
  end

  def create
    @game = Game.create!
    @games = Game.all
    render :index
  end

  def show
    @game = Game.find(params[:id])
    @hand = @game.hands.last
  end
end
