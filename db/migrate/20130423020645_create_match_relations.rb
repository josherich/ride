class CreateMatchRelations < ActiveRecord::Migration
  def change
    create_table :match_relations do |t|
      t.integer :match_request_id
      t.integer :route_id

      t.timestamps
    end
    add_index :match_relations, :match_request_id
    add_index :match_relations, :route_id
  end
end
