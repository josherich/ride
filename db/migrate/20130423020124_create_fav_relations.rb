class CreateFavRelations < ActiveRecord::Migration
  def change
    create_table :fav_relations do |t|
      t.integer :follower_id
      t.integer :route_id

      t.timestamps
    end
    add_index :fav_relations, :follower_id
    add_index :fav_relations, :route_id
  end
end
