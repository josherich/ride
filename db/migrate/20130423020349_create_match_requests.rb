class CreateMatchRequests < ActiveRecord::Migration
  def change
    create_table :match_requests do |t|
      t.string :from
      t.string :to
      t.string :lat_s
      t.string :lng_s
      t.string :lat_d
      t.string :lng_d
      t.integer :user_id
      t.integer :freq_pattern
      t.time :arrive_time

      t.timestamps
    end
    add_index :match_requests, :user_id
  end
end
