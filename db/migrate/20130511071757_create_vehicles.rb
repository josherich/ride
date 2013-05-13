class CreateVehicles < ActiveRecord::Migration
  def change
    create_table :vehicles do |t|
    	t.string :license
    	t.string :brand
    	t.string :model
    	t.integer :seat_stat
    	t.integer :color
    	t.integer :type
    	t.integer :driver_id
    	t.date :purch_date
      t.timestamps
    end
    add_index :vehicles, :driver_id
  end
end
