class CreateHands < ActiveRecord::Migration
  def change
    create_table :hands do |t|
      t.references :game
      t.references :action_player, references: :players
      t.float :sb
      t.float :bb
      t.string :round
      t.string :flop
      t.string :turn
      t.string :river
      t.float :pot
      t.timestamps
    end
  end
end
