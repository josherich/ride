class ChangeSeatStat < ActiveRecord::Migration
  def up
  	remove_column :route_records, :seat_stat
  	add_column :route_records, :seat_stat, :float
  end

  def down
  end
end
