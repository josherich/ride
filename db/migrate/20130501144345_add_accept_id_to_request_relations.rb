class AddAcceptIdToRequestRelations < ActiveRecord::Migration
  def change
  	add_column :request_relations, :accept_id, :integer
  end
end
