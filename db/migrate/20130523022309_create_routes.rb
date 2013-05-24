class CreateRoutes < ActiveRecord::Migration
  def change
    create_table :routes do |t|
      t.string :from
      t.string :to
      t.string :data
      t.string :lat_s
      t.string :lng_s
      t.string :lat_d
      t.string :lng_d
      t.integer :user_id
      t.integer :timespan
      t.integer :freq_pattern
      t.integer :seat_stat
      t.integer :price
      t.boolean :isactive
      t.boolean :isdriver
      t.time :set_time
      t.date :set_date

      t.timestamps
    end
    add_index  :route_records, :user_id
  end
end
