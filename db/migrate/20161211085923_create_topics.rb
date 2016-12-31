class CreateTopics < ActiveRecord::Migration[5.0]
  def change
    create_table :topics do |t|
      t.string :text
      t.integer :weight

      t.timestamps
    end

    add_index :topics, :weight
  end
end
