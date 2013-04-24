class CreateRequestRelations < ActiveRecord::Migration
  def change
    create_table :request_relations do |t|
      t.integer :req_id
      t.integer :reqed_id
      t.integer :stat_id

      t.timestamps
    end
  end
end
