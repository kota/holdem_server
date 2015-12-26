class CreateGames < ActiveRecord::Migration
  def change
    create_table :games do |t|
      t.string :state
      t.references :current_button_player, references: :players
      t.timestamps
    end
  end
end
