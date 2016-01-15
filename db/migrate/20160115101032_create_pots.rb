class CreatePots < ActiveRecord::Migration
  def change
    create_table :pots do |t|
      t.float :amount
      t.references :hand
      t.timestamps
    end
  end
end
