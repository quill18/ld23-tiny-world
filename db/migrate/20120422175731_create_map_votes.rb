class CreateMapVotes < ActiveRecord::Migration
  def change
    create_table :map_votes do |t|
      t.integer :map_id
      t.integer :user_id
      t.integer :vote

      t.timestamps
    end

    add_index :map_votes, :map_id
    add_index :map_votes, :user_id
  end
end
