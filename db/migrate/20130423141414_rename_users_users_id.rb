class RenameUsersUsersId < ActiveRecord::Migration
  def up
  	remove_column :route_records, :user_id
  	add_column :route_records, :user_id, :integer
  end

  def down
  end
end
