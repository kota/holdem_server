class CreateHandActions < ActiveRecord::Migration
  def change
    create_table :hand_actions do |t|
      t.references :hand
      t.references :player
      t.string :action_type
      t.string :round
      t.float :bet_amount
      t.timestamps
    end
  end
end
