class CreatePlayers < ActiveRecord::Migration
  def change
    create_table :players do |t|
      t.references :user
      t.references :game
      t.references :hand
      t.float :chip, default: 0
      t.string :hole_cards
      t.boolean :folded, default: false
      t.integer :position
      t.timestamps
    end
  end
end
