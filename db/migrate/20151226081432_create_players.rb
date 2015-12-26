class CreatePlayers < ActiveRecord::Migration
  def change
    create_table :players do |t|
      t.references :user
      t.references :game
      t.references :hand
      t.float :chip
      t.string :hole_cards
      t.boolean :folded
      t.timestamps
    end
  end
end
